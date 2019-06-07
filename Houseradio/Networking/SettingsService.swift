//
//  SettingsService.swift
//  Houseradio
//
//  Created by Pawel Rup on 15/10/2018.
//  Copyright © 2018 Pawel Rup. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SettingsService {
	
	// MARK: - Properties
	
	private let urlSession: URLSession
	
	// MARK: - Initialization
	
	init(urlSession: URLSession) {
		self.urlSession = urlSession
	}
	
	// MARK: - Functions
	
	func getSettings() -> Observable<Settings> {
		let request = URLRequest(url: Environment.Api.configuration)
		return urlSession.rx.data(request: request)
			.map { try JSONDecoder().decode(Settings.self, from: $0) }
			.do(onNext: { $0.save() })
			.catchErrorJustReturn(.current)
	}
}
