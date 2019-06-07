//
//  LanguagesManager.swift
//  Houseradio
//
//  Created by Pawel Rup on 24/02/2019.
//  Copyright © 2019 Pawel Rup. All rights reserved.
//

import Foundation
import RxSwift

class LanguagesManager {

	static func getLanguage(for code: String) -> Single<Language> {
		let queryItem = URLQueryItem(name: "code", value: code)
		var urlComponents = URLComponents(url: Environment.Api.searchLanguage, resolvingAgainstBaseURL: true)!
		urlComponents.queryItems = [queryItem]
		let url = urlComponents.url!
		let request = URLRequest(url: url)
		return URLSession.shared.rx.data(request: request)
			.map { try JSONDecoder().decode(Language.self, from: $0) }
			.asSingle()
	}
}
