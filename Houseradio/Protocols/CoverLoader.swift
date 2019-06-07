//
//  CoverLoader.swift
//  Houseradio
//
//  Created by Pawel Rup on 07/06/2019.
//  Copyright © 2019 Pawel Rup. All rights reserved.
//

import Foundation
import RxSwift

protocol CoverLoader {
	func loadCover(for text: String) -> Observable<Cover>

	init(urlSession: URLSession, coverDirectory: URL)
}
