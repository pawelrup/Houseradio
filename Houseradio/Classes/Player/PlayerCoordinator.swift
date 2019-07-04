//
//  PlayerCoordinator.swift
//  Houseradio
//
//  Created by Pawel Rup on 15/10/2018.
//  Copyright © 2018 Pawel Rup. All rights reserved.
//

import UIKit
import SafariServices
import RxSwift
import RxRadioPlayer

class PlayerCoordinator: BaseCoordinator<Void> {
	
	// MARK: - Properties

	private let nowPlayingInfoCenter = NowPlayingInfoCenter()
	private let rootViewController: UIViewController
	
	// MARK: - Initialization
	
	init(rootViewController: UIViewController) {
		self.rootViewController = rootViewController
	}
	
	// MARK: - Overrides
	
	override func start() -> Observable<Void> {
		let urlSession = URLSession.shared
		let settings = Settings.current
		let radioPlayer = AppDelegate.shared.radioPlayer
		radioPlayer.radioURL = settings.shoutcastURL
		let coverLoader = CoverLoaderInstance(urlSession: urlSession, coverDirectory: settings.coversURL)
		let metadataLoader = ShoutCASTMetadataLoader(urlSession: urlSession, url: settings.shoutcastURL)
		let playerServices = PlayerServices(radioPlayer: radioPlayer, settings: settings, coverLoader: coverLoader, metadataLoader: metadataLoader, nowPlayingInfoCenter: nowPlayingInfoCenter)
		let viewController = PlayerViewController.instantiate(withServices: playerServices)
		
		let openFanpage = viewController.viewModel
			.openFanpage
			.share()
		openFanpage
			.compactMap {
				let appURL = $0.appURL.appendingPathComponent($0.profileID)
				if UIApplication.shared.canOpenURL(appURL) {
					return appURL
				}
				return nil
			}
			.subscribe(onNext: { UIApplication.shared.open($0) })
			.disposed(by: disposeBag)
		openFanpage
			.compactMap {
				let appURL = $0.appURL.appendingPathComponent($0.profileID)
				if !UIApplication.shared.canOpenURL(appURL) {
					return $0.webURL.appendingPathComponent($0.profileID)
				}
				return nil
			}
			.subscribe(onNext: { [unowned self, unowned viewController] in
				self.showFanpage(by: $0, in: viewController)
			})
			.disposed(by: disposeBag)
		viewController.viewModel
			.performShare
			.subscribe(onNext: { [unowned self, weak viewController] in
				guard let viewController = viewController else { return }
				self.showShare(with: $0, in: viewController, from: viewController.shareButton)
			})
			.disposed(by: disposeBag)
		viewController.viewModel
			.toggledPlayPause
			.map { StoreKitManager(minimumLaunchTimes: Environment.minimumLaunchCountForRating) }
			.subscribe(onNext: { $0.displayStoreKit() })
			.disposed(by: disposeBag)
		
		let navigationController = NavigationController(rootViewController: viewController)
		navigationController.navigationBar.barTintColor = .primary
		navigationController.modalTransitionStyle = .crossDissolve
		navigationController.modalPresentationStyle = .fullScreen
		rootViewController.present(navigationController, animated: true)
		
		return Observable.never()
	}
	
	// MARK: - Show player view
	
	private func showFanpage(by url: URL, in viewController: UIViewController) {
		let safariViewController = SFSafariViewController(url: url)
		safariViewController.preferredBarTintColor = .primary
		safariViewController.preferredControlTintColor = .white
		viewController.present(safariViewController, animated: true)
	}
	
	private func showShare(with metadata: Metadata, in viewController: UIViewController, from barButtonItem: UIBarButtonItem) {
		let artist = metadata.artist
		let title = metadata.title
		let text = artist.isEmpty ? title : String(format: "%@ - %@", artist, title)
		
		// swiftlint:disable:next force_https
		let activityItem = String(format: "I'm listening to %@ on #houseradio right now.\nCheck it out!\nhttp://www.houseradio.pl".localized, text)
		let activityViewController = UIActivityViewController(activityItems: [activityItem], applicationActivities: nil)
		
		if let popoverController = activityViewController.popoverPresentationController {
			popoverController.barButtonItem = barButtonItem
			popoverController.permittedArrowDirections = .up
		}
		viewController.present(activityViewController, animated: true, completion: nil)
	}
}
