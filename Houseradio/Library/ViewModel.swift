//
//  ViewModel.swift
//  Houseradio
//
//  Created by Pawel Rup on 03/03/2019.
//  Copyright © 2019 Pawel Rup. All rights reserved.
//

import Foundation

protocol ViewModel {
	associatedtype Services
	init(withServices services: Services)
}
