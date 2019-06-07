//
//  StoreKitManager.swift
//  Houseradio
//
//  Created by Pawel Rup on 17/04/2019.
//  Copyright © 2019 Pawel Rup. All rights reserved.
//

import Foundation
import StoreKit

class StoreKitManager {
	static private let numberOfTimesLaunchedKey = "numberOfTimesLaunched"
	static private let lastVersionKey = "lastVersion"
	private let minimumLaunchTimes: Int

	init(minimumLaunchTimes: Int) {
		self.minimumLaunchTimes = minimumLaunchTimes
	}

	func displayStoreKit() {
		guard let currentVersion = Bundle.main.bundleShortVersion else {
			return
		}
		let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: StoreKitManager.lastVersionKey)
		let numberOfTimesLaunched = UserDefaults.standard.integer(forKey: StoreKitManager.numberOfTimesLaunchedKey)

		if numberOfTimesLaunched >= minimumLaunchTimes && currentVersion != lastVersionPromptedForReview {
			SKStoreReviewController.requestReview()
			UserDefaults.standard.set(currentVersion, forKey: StoreKitManager.lastVersionKey)
		}
	}

	static func incrementNumberOfTimesLaunched() {
		let numberOfTimesLaunched = UserDefaults.standard.integer(forKey: StoreKitManager.numberOfTimesLaunchedKey) + 1
		UserDefaults.standard.set(numberOfTimesLaunched, forKey: StoreKitManager.numberOfTimesLaunchedKey)
	}
}
