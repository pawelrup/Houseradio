//
//  UIDevice+Extensions.swift
//  Houseradio
//
//  Created by Pawel Rup on 24/02/2019.
//  Copyright © 2019 Pawel Rup. All rights reserved.
//

import UIKit

extension UIDevice {

	var modelName: String {
		var systemInfo = utsname()
		uname(&systemInfo)
		let machineMirror = Mirror(reflecting: systemInfo.machine)
		let identifier = machineMirror.children.reduce("") { identifier, element in
			guard let value = element.value as? Int8, value != 0 else { return identifier }
			return identifier + String(UnicodeScalar(UInt8(value)))
		}
		return identifier
	}
}
