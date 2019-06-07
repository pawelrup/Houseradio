//
//  MetadataLoader.swift
//  Houseradio
//
//  Created by Pawel Rup on 07/06/2019.
//  Copyright © 2019 Pawel Rup. All rights reserved.
//

import Foundation
import RxSwift
import RxRadioPlayer

protocol MetadataLoader {
	var isLoading: AnyObserver<Bool> { get }
	var metadata: Observable<Metadata> { get }

	init(urlSession: URLSession)
}
