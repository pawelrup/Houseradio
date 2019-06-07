//
//  LoadingSettingsViewModel.swift
//  Houseradio
//
//  Created by Pawel Rup on 15/10/2018.
//  Copyright © 2018 Pawel Rup. All rights reserved.
//

import Foundation
import RxSwift

class LoadingSettingsViewModel: ViewModel {

	typealias Services = SettingsService
	
	// MARK: - Outputs
	
	let settings: Observable<Settings>
	
	// MARK: - Initialization
	
	required init(withServices settingsService: SettingsService) {
		self.settings = settingsService.getSettings()
			.observeOn(MainScheduler.instance)
	}
}
