//
//  LoadingSettingsViewController.swift
//  Houseradio
//
//  Created by Pawel Rup on 15/10/2018.
//  Copyright © 2018 Pawel Rup. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoadingSettingsViewController: UIViewController {

	var viewModel: LoadingSettingsViewModel!

	private let disposeBag = DisposeBag()
	
	// MARK: - Overrides
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .default
	}
	
	override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
		return .fade
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		setNeedsStatusBarAppearanceUpdate()
	}
}

// MARK: - StoryboardBased
extension LoadingSettingsViewController: StoryboardBased {

	static var storyboardName: String {
		return "LoadingSettings"
	}
}

extension LoadingSettingsViewController: ViewModelBased { }
