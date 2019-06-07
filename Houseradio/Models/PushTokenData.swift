//
//  PushTokenData.swift
//  Houseradio
//
//  Created by Pawel Rup on 24/02/2019.
//  Copyright © 2019 Pawel Rup. All rights reserved.
//

import Foundation

struct PushTokenData: Codable {
	let token: String
	let languageID: Int
	let deviceModelIdentifier: String
	let systemVersion: String
	let appVersion: String

	init(token: String, languageID: Int, deviceModelIdentifier: String, systemVersion: String, appVersion: String) {
		self.token = token
		self.languageID = languageID
		self.deviceModelIdentifier = deviceModelIdentifier
		self.systemVersion = systemVersion
		self.appVersion = appVersion
	}
}
