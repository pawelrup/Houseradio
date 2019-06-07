//
//  PlayerViewController.swift
//  Houseradio
//
//  Created by Pawel Rup on 15/10/2018.
//  Copyright © 2018 Pawel Rup. All rights reserved.
//

import UIKit
import MediaPlayer
import RxSwift
import RxCocoa
import RxAnimated
import AVKit

class PlayerViewController: UIViewController {
	
	// MARK: - Outlets
	
	@IBOutlet private weak var facebookButton: UIBarButtonItem! {
		didSet {
			facebookButton.accessibilityLabel = "Facebook"
			facebookButton.accessibilityTraits = .button
			facebookButton.accessibilityHint = "Tap twice to open houseradio fanpage.".localized
		}
	}
	@IBOutlet private (set) weak var shareButton: UIBarButtonItem! {
		didSet {
			shareButton.accessibilityLabel = "Share".localized
			shareButton.accessibilityTraits = .button
			shareButton.accessibilityHint = "Tap twice to share".localized
		}
	}
	@IBOutlet private weak var coverImageView: UIImageView! {
		didSet {
			coverImageView.isAccessibilityElement = false
		}
	}
	@IBOutlet private weak var controlsContainerView: UIView!
	@IBOutlet private weak var playActivityIndicator: UIActivityIndicatorView! {
		didSet {
			playActivityIndicator.isAccessibilityElement = false
		}
	}
	@IBOutlet private weak var playButton: UIButton!
	@IBOutlet private weak var labelsStackView: UIStackView!
	@IBOutlet private weak var artistLabel: UILabel!
	@IBOutlet private weak var titleLabel: UILabel!
	@IBOutlet private weak var routePickerStackView: UIStackView!
	@IBOutlet private weak var routePickerView: AVRoutePickerView! {
		didSet {
			routePickerView.activeTintColor = .white
		}
	}
	@IBOutlet private weak var routeNameLabel: UILabel!

	// MARK: - Properties
	
	private let disposeBag = DisposeBag()
	var viewModel: PlayerViewModel!
	
	// MARK: - Overrides
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
		return .fade
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupBindings()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		setNeedsStatusBarAppearanceUpdate()
	}
	
	// MARK: - Functions
	
	private func setupBindings() {
		let metadata = viewModel.metadata
			.share()
		metadata
			.map { $0?.artist }
			.bind(to: artistLabel.rx.text)
			.disposed(by: disposeBag)
		metadata
			.map { $0?.title }
			.bind(to: titleLabel.rx.text)
			.disposed(by: disposeBag)
		let isLoading = viewModel.isLoading
			.share()
		isLoading
			.bind(to: playButton.rx.isHidden)
			.disposed(by: disposeBag)
		isLoading
			.bind(to: playActivityIndicator.rx.isAnimating)
			.disposed(by: disposeBag)
		viewModel.playbackState
			.map { state in
				switch state {
				case .paused:
					return #imageLiteral(resourceName: "play")
				case .stopped, .playing:
					return #imageLiteral(resourceName: "pause")
				}
			}
			.bind(to: playButton.rx.image())
			.disposed(by: disposeBag)
		viewModel.isFacebookButtonEnabled
			.bind(to: facebookButton.rx.isEnabled)
			.disposed(by: disposeBag)
		viewModel.cover
			.map { $0.image }
			.bind(animated: coverImageView.rx.animated.fade(duration: 0.3).image)
			.disposed(by: disposeBag)
		viewModel.multipleRoutesDetected
			.map { !$0 }
			.bind(animated: routePickerStackView.rx.animated.fade(duration: 0.3).isHidden)
			.disposed(by: disposeBag)
		viewModel.routeName
			.map { $0?.portType != .builtInSpeaker ? $0?.portName : nil }
			.bind(to: routeNameLabel.rx.text)
			.disposed(by: disposeBag)
		facebookButton.rx
			.tap
			.bind(to: viewModel.toggleFanpage)
			.disposed(by: disposeBag)
		shareButton.rx
			.tap
			.bind(to: viewModel.toggleShare)
			.disposed(by: disposeBag)
		playButton.rx
			.controlEvent(.touchUpInside)
			.bind(to: viewModel.togglePlayPause)
			.disposed(by: disposeBag)
	}
}

extension PlayerViewController: StoryboardBased {

	static var storyboardName: String {
		return "Player"
	}
}

extension PlayerViewController: ViewModelBased { }
