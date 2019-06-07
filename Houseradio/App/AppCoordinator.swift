//
//  AppCoordinator.swift
//  Houseradio
//
//  Created by Pawel Rup on 15/10/2018.
//  Copyright © 2018 Pawel Rup. All rights reserved.
//

import UIKit
import RxSwift

class AppCoordinator: BaseCoordinator<Void> {
	
	private let window: UIWindow
	
	init(window: UIWindow) {
		self.window = window
	}
	
	override func start() -> Observable<Void> {
		let loadingSettingsCoordinator = LoadingSettingsCoordinator(window: window)
		return coordinate(to: loadingSettingsCoordinator)
	}
}
