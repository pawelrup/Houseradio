//
//  StoryboardBased.swift
//  Houseradio
//
//  Created by Pawel Rup on 15/10/2018.
//  Copyright © 2018 Pawel Rup. All rights reserved.
//

import UIKit

public protocol StoryboardBased: class {
	static var storyboard: UIStoryboard { get }
	static var storyboardName: String { get }
}

public extension StoryboardBased {
	static var storyboard: UIStoryboard {
		return UIStoryboard(name: storyboardName, bundle: Bundle(for: self))
	}

	static var storyboardName: String {
		return String(describing: self)
	}
}

public extension StoryboardBased where Self: UIViewController {
	static func instantiate() -> Self {
		guard let viewController = storyboard.instantiateInitialViewController() as? Self else {
			fatalError("The view controller of \(storyboardName) is not of class \(self)")
		}
		return viewController
	}
}
