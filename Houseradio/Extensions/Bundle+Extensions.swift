//
//  Bundle+Extensions.swift
//  Houseradio
//
//  Created by Pawel Rup on 24/02/2019.
//  Copyright © 2019 Pawel Rup. All rights reserved.
//

import Foundation

extension Bundle {

	var bundleShortVersion: String? {
		return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
	}
}
