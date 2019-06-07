//
//  String+Extensions.swift
//  Houseradio
//
//  Created by Pawel Rup on 16/10/2018.
//  Copyright © 2018 Pawel Rup. All rights reserved.
//

import Foundation

extension String {
	
	/// Returns localized string for key string
	var localized: String {
		return NSLocalizedString(self, comment: self)
	}
}
