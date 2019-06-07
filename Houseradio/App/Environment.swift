//
//  Interfaces.swift
//  Houseradio
//
//  Created by Pawel Rup on 13/04/2019.
//  Copyright © 2019 Pawel Rup. All rights reserved.
//

import Foundation

// MARK: - Keys

private enum Keys {
	enum Plist {
		static let appID = "APP_ID"
		static let rootURL = "ROOT_URL"
		static let shoutcastURL = "SHOUTCAST_URL"
		static let coversDirectory = "COVERS_DIRECTORY"
		static let minimumLaunchCountForRating = "MINIMUM_LAUNCH_COUNT_FOR_RATING"
	}
}

public enum Environment {

	// MARK: - Plist

	private static let infoDictionary: [String: Any] = {
		guard let dict = Bundle.main.infoDictionary else {
			fatalError("Plist file not found")
		}
		return dict
	}()

	// MARK: - Plist values

	static let appID: String = {
		guard let appID = Environment.infoDictionary[Keys.Plist.appID] as? String else {
			fatalError("App ID is not set in plist for this environment")
		}
		return appID
	}()

	static let rootURL: URL = {
		guard let apiURLString = Environment.infoDictionary[Keys.Plist.rootURL] as? String else {
			fatalError("Api URL is not set in plist for this environment")
		}
		guard let url = URL(string: apiURLString) else {
			fatalError("Api URL is invalid")
		}
		return url
	}()

	static let shoutcastURL: URL = {
		guard let apiURLString = Environment.infoDictionary[Keys.Plist.shoutcastURL] as? String else {
			fatalError("Shoutcast URL is not set in plist for this environment")
		}
		guard let url = URL(string: apiURLString) else {
			fatalError("Shoutcast URL is invalid")
		}
		return url
	}()

	static let coversDirectory: String = {
		guard let coversDirectory = Environment.infoDictionary[Keys.Plist.coversDirectory] as? String else {
			fatalError("Covers directory is not set in plist for this environment")
		}
		return coversDirectory
	}()

	static let minimumLaunchCountForRating: Int = {
		guard let countValue = Environment.infoDictionary[Keys.Plist.minimumLaunchCountForRating] as? String else {
			fatalError("Minimum launch count for rating is not set in plist for this environment")
		}
		guard let count = Int(countValue) else {
			fatalError("Minimum launch count for rating is not an Int value")
		}
		return count
	}()

	struct Api {

		private static var baseURL: URL {
			return Environment.rootURL.appendingPathComponent("api")
		}

		static var configuration: URL {
			return baseURL.appendingPathComponent("configuration")
		}

		static var covers: URL {
			return baseURL.appendingPathComponent("covers")
		}

		static var tokens: URL {
			return baseURL.appendingPathComponent("tokens")
		}

		static var searchLanguage: URL {
			return baseURL
				.appendingPathComponent("languages")
				.appendingPathComponent("search")
		}
	}
}
