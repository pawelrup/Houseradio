//
//  LoadingSettingsCoordinator.swift
//  Houseradio
//
//  Created by Pawel Rup on 15/10/2018.
//  Copyright © 2018 Pawel Rup. All rights reserved.
//

import UIKit
import RxSwift

class LoadingSettingsCoordinator: BaseCoordinator<Void> {
	
	// MARK: - Properties
	
	private let window: UIWindow
	
	// MARK: - Initialization
	
	init(window: UIWindow) {
		self.window = window
	}
	
	// MARK: - Overrides
	
	override func start() -> Observable<Void> {
		let sessionConfiguration = URLSessionConfiguration.default
		sessionConfiguration.timeoutIntervalForRequest = 10
		let urlSession = URLSession(configuration: sessionConfiguration)
		let settingsService = SettingsService(urlSession: urlSession)
		let viewController = LoadingSettingsViewController.instantiate(withServices: settingsService)

		viewController.viewModel
			.settings
			.map { _ in () }
			.flatMap { [unowned self, unowned viewController] in
				self.showPlayer(on: viewController)
			}
			.subscribe()
			.disposed(by: disposeBag)
		
		window.rootViewController = viewController
		window.makeKeyAndVisible()
		
		return Observable.never()
	}
	
	// MARK: - Show player view
	
	private func showPlayer(on rootViewController: UIViewController) -> Observable<Void> {
		let playerCoordinator = PlayerCoordinator(rootViewController: rootViewController)
		return coordinate(to: playerCoordinator)
	}
}
