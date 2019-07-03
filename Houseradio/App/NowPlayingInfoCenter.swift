//
//  NowPlayingInfoCenter.swift
//  Houseradio
//
//  Created by Pawel Rup on 08/06/2019.
//  Copyright © 2019 Pawel Rup. All rights reserved.
//

import Foundation
import MediaPlayer
import RxSwift
import RxRadioPlayer

class NowPlayingInfoCenter {

	private let disposeBag = DisposeBag()

	var nowPlayingInfo: AnyObserver<NowPlayingInfo>
	var playbackState: AnyObserver<RadioPlayerPlaybackState>

	init() {
		let nowPlayingInfoSubject = PublishSubject<NowPlayingInfo>()
		let playbackStateSubject = PublishSubject<RadioPlayerPlaybackState>()
		nowPlayingInfo = nowPlayingInfoSubject.asObserver()
		playbackState = playbackStateSubject.asObserver()

		nowPlayingInfoSubject
			.subscribe(onNext: { info in
				let coverItem = MPMediaItemArtwork(boundsSize: info.artwork.size) { (_: CGSize) -> UIImage in
					return info.artwork
				}
				var nowPlayingInfo = [String: Any]()
				nowPlayingInfo[MPMediaItemPropertyArtist] = info.artist
				nowPlayingInfo[MPMediaItemPropertyTitle] = info.title
				nowPlayingInfo[MPMediaItemPropertyArtwork] = coverItem
				MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
			})
			.disposed(by: disposeBag)
		playbackStateSubject
			.map { $0.mpNowPlayingPlaybackState }
			.subscribe(onNext: { playbackState in
				if #available(iOS 13.0, *) {
					MPNowPlayingInfoCenter.default().playbackState = playbackState
				}
			})
			.disposed(by: disposeBag)
	}
}

private extension RadioPlayerPlaybackState {

	var mpNowPlayingPlaybackState: MPNowPlayingPlaybackState {
		switch self {
		case .paused:
			return .paused
		case .playing:
			return .playing
		case .stopped:
			return .stopped
		}
	}
}
