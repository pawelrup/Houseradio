//
//  ViewModelBased.swift
//  Houseradio
//
//  Created by Pawel Rup on 03/03/2019.
//  Copyright © 2019 Pawel Rup. All rights reserved.
//

import UIKit

protocol ViewModelBased: class {
	associatedtype ViewModelType: ViewModel
	var viewModel: ViewModelType! { get set }
}

extension ViewModelBased where Self: StoryboardBased & UIViewController {
	static func instantiate(with viewModel: ViewModelType) -> Self {
		let viewController = Self.instantiate()
		viewController.viewModel = viewModel
		return viewController
	}
}

extension ViewModelBased where Self: StoryboardBased & UIViewController {
	static func instantiate<ServicesT>(withServices services: ServicesT) -> Self
		where ServicesT == Self.ViewModelType.Services {
			let viewController = Self.instantiate()
			viewController.viewModel = ViewModelType(withServices: services)
			return viewController
	}
}
