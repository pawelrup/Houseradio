//
//  NavigationController.swift
//  Houseradio
//
//  Created by Pawel Rup on 15/10/2018.
//  Copyright © 2018 Pawel Rup. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

	// MARK: - Overrides
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return topViewController?.preferredStatusBarStyle ?? .default
	}
	
	override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
		return topViewController?.preferredStatusBarUpdateAnimation ?? .none
	}
}
