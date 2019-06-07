//
//  Cover.swift
//  Houseradio
//
//  Created by Pawel Rup on 16/10/2018.
//  Copyright © 2018 Pawel Rup. All rights reserved.
//

import UIKit

struct Cover {
	static let `default` = Cover(image: #imageLiteral(resourceName: "hr"), infoCenterImage: #imageLiteral(resourceName: "hrLockscreen"))
	
	let image: UIImage
	let infoCenterImage: UIImage
	
	init(image: UIImage) {
		self.image = image
		self.infoCenterImage = image
	}
	
	init(image: UIImage, infoCenterImage: UIImage) {
		self.image = image
		self.infoCenterImage = infoCenterImage
	}
}
