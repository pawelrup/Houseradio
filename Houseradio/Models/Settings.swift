//
//  Settings.swift
//  Houseradio
//
//  Created by Pawel Rup on 15/10/2018.
//  Copyright © 2018 Pawel Rup. All rights reserved.
//

import Foundation

class Settings: Codable {

	private static var savedSettingsURL: URL {
		return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Settings.plist")
	}

	private static var `default`: Settings {
		return Settings(facebook: nil, shoutcastURL: Environment.shoutcastURL, appID: Environment.appID, coversDirectory: Environment.coversDirectory)
	}

	init(facebook: FacebookData?, shoutcastURL: URL, appID: String, coversDirectory: String) {
		self.facebook = facebook
		self.shoutcastURL = shoutcastURL
		self.appID = appID
		self.coversDirectory = coversDirectory
	}
	
	let facebook: FacebookData?
	let shoutcastURL: URL
	let appID: String
	let coversDirectory: String
	var coversURL: URL {
		return Environment.rootURL.appendingPathComponent(coversDirectory)
	}
	
	static var current: Settings {
		var settings = Settings.default
		if FileManager.default.fileExists(atPath: savedSettingsURL.path) {
			let settingsData = FileManager.default.contents(atPath: savedSettingsURL.path)!
			do {
				let settingsDict = try PropertyListSerialization.propertyList(from: settingsData, options: .mutableContainersAndLeaves, format: nil) as! [AnyHashable: Any]
				let jsonData = try JSONSerialization.data(withJSONObject: settingsDict, options: .sortedKeys)
				settings = try JSONDecoder().decode(Settings.self, from: jsonData)
			} catch {
				debugPrint(error.localizedDescription)
			}
		}
		return settings
	}
	
	func save() {
		do {
			let encoded = try JSONEncoder().encode(self)
			let dict = try JSONSerialization.jsonObject(with: encoded) as! NSDictionary
			try dict.write(to: Settings.savedSettingsURL)
		} catch {
			fatalError(error.localizedDescription)
		}
	}
}
