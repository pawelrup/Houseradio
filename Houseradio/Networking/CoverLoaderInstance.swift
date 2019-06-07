//
//  CoverLoader.swift
//  Houseradio
//
//  Created by Pawel Rup on 15/10/2018.
//  Copyright © 2018 Pawel Rup. All rights reserved.
//

import UIKit
import RxSwift

class CoverLoaderInstance: CoverLoader {

	private struct CoverData: Codable {
		let name: String
		let filename: String
	}

	private let urlSession: URLSession
	private let coverDirectory: URL

	required init(urlSession: URLSession, coverDirectory: URL) {
		self.urlSession = urlSession
		self.coverDirectory = coverDirectory
	}
	
	func loadCover(for text: String) -> Observable<Cover> {
		let queryItem = URLQueryItem(name: "name", value: text)
		var urlComponents = URLComponents(url: Environment.Api.covers, resolvingAgainstBaseURL: true)!
		urlComponents.queryItems = [queryItem]
		let url = urlComponents.url!
		let request = URLRequest(url: url)
		return urlSession.rx.data(request: request)
			.map { try JSONDecoder().decode(CoverData.self, from: $0) }
			.map { [weak self] in
				return self?.coverDirectory.appendingPathComponent($0.filename)
			}
			.compactMap { $0 }
			.map { URLRequest(url: $0) }
			.flatMapLatest { URLSession.shared.rx.data(request: $0) }
			.map(UIImage.init)
			.map { image in
				if let image = image {
					return Cover(image: image)
				}
				return Cover.default
			}
			.catchErrorJustReturn(.default)
	}
}
