//
//  PushTokensManager.swift
//  Houseradio
//
//  Created by Pawel Rup on 24/02/2019.
//  Copyright © 2019 Pawel Rup. All rights reserved.
//

import UIKit
import RxSwift

class PushTokensManager {

	static func send(tokenData: PushTokenData) -> Single<Data> {
		var request = URLRequest(url: Environment.Api.tokens)
		request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
		request.httpMethod = "POST"
		request.httpBody = try? JSONEncoder().encode(tokenData)
		return URLSession.shared.rx.data(request: request)
			.asSingle()
	}
}
