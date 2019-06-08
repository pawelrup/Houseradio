//
//  MetadataLoader.swift
//  Houseradio
//
//  Created by Pawel Rup on 14/04/2019.
//  Copyright © 2019 Pawel Rup. All rights reserved.
//

import Foundation
import RxSwift
import RxRadioPlayer

class ShoutCASTMetadataLoader: MetadataLoader {

	private let isLoadingSubject = BehaviorSubject<Bool>(value: false)
	private let metadataSubject = PublishSubject<Metadata>()
	private let disposeBag = DisposeBag()
	private let urlSession: URLSession
	private var url: URL?

	var isLoading: AnyObserver<Bool>
	var metadata: Observable<Metadata>

	required init(urlSession: URLSession) {
		self.urlSession = urlSession

		isLoading = isLoadingSubject.asObserver()
		metadata = metadataSubject.asObservable()

		bindObservables()
	}

	convenience init(urlSession: URLSession, url: URL) {
		self.init(urlSession: urlSession)
		self.url = url
	}

	private func bindObservables() {
		isLoadingSubject
			.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
			.flatMapLatest { isPlaying in
				isPlaying ? .empty() : Observable.just(0).concat(Observable<Int>.interval(.seconds(5), scheduler: MainScheduler.instance))
			}
			.compactMap { [weak self] _ in self?.url }
			.flatMapLatest { [unowned self] in self.load(from: $0).asObservable() }
			.observeOn(MainScheduler.instance)
			.bind(to: metadataSubject)
			.disposed(by: disposeBag)
	}

	private func load(from url: URL) -> Single<Metadata> {
		let url = url.appendingPathComponent("7.html")
		var request = URLRequest(url: url)
		request.setValue("Mozilla/1.0 SHOUTcast example", forHTTPHeaderField: "user-agent")
		return urlSession.rx.data(request: request)
			.map { data in
				return String(data: data, encoding: .utf8)
			}
			.compactMap { $0 }
			.compactMap { [weak self] in
				self?.extractMetadataString(from: $0)
			}
			.map(MetadataItem.init)
			.catchError { error -> Observable<Metadata> in
				let errorMetadata = MetadataItem(artist: "Connection failed.", title: error.localizedDescription)
				return Observable.just(errorMetadata)
			}
			.asSingle()
	}

	private func extractMetadataString(from string: String) -> String {
		var str = string
		if let startRange = str.range(of: "<body>"), let endRange = str.range(of: "</body>") {
			str = String(str[startRange.upperBound..<endRange.lowerBound])
			let arr = str.components(separatedBy: ",")
			var string = ""
			if arr.count <= 7 {
				string = arr[arr.count-1]
			} else {
				string = arr[6]
				for index in 7 ..< arr.count {
					string += ",\(arr[index])"
				}
			}
			str = string
		}
		return str
	}
}
