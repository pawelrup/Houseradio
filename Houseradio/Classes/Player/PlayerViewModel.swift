//
//  PlayerViewModel.swift
//  Houseradio
//
//  Created by Pawel Rup on 15/10/2018.
//  Copyright © 2018 Pawel Rup. All rights reserved.
//

import Foundation
import RxSwift
import RxRadioPlayer
import AVKit

protocol HasRadioPlayer {
	var radioPlayer: RadioPlayerType { get }
}

protocol HasSettings {
	var settings: Settings { get }
}

protocol HasCoverLoader {
	var coverLoader: CoverLoader { get }
}

protocol HasMetadataLoader {
	var metadataLoader: MetadataLoader { get }
}

protocol HasNowPlayingInfoCenter {
	var nowPlayingInfoCenter: NowPlayingInfoCenter { get }
}

struct PlayerServices: HasRadioPlayer, HasSettings, HasCoverLoader, HasMetadataLoader, HasNowPlayingInfoCenter {
	let radioPlayer: RadioPlayerType
	let settings: Settings
	let coverLoader: CoverLoader
	let metadataLoader: MetadataLoader
	let nowPlayingInfoCenter: NowPlayingInfoCenter
}

class PlayerViewModel: ViewModel {

	typealias Services = HasRadioPlayer & HasSettings & HasCoverLoader & HasMetadataLoader & HasNowPlayingInfoCenter
	
	// MARK: - Properties
	
	private var radioPlayer: RadioPlayerType
	private let settings: Settings
	private let coverLoader: CoverLoader
	private let metadataLoader: MetadataLoader
	private let nowPlayingInfoCenter: NowPlayingInfoCenter
	private let disposeBag = DisposeBag()

	private let togglePlayPauseSubject = PublishSubject<Void>()
	private let toggleShareSubject = PublishSubject<Void>()
	private let toggleFanpageSubject = PublishSubject<Void>()

	private let metadataSubject = BehaviorSubject<Metadata?>(value: nil)
	private let playbackStateSubject = PublishSubject<RadioPlayerPlaybackState>()
	private let stateSubject = PublishSubject<RadioPlayerState>()
	private let toggledPlayPauseSubject = PublishSubject<Void>()
	private let isPlayingSubject = PublishSubject<Bool>()
	private let isLoadingSubject = PublishSubject<Bool>()
	private let isFacebookButtonEnabledSubject = PublishSubject<Bool>()
	private let coverSubject = PublishSubject<Cover>()

	private let openFanpageSubject = PublishSubject<FacebookData>()
	private let performShareSubject = PublishSubject<Metadata>()
	private let multipleRoutesDetectedSubject = BehaviorSubject<Bool>(value: AppDelegate.shared.routeDetector.multipleRoutesDetected)
	private let routeNameSubject = BehaviorSubject<AVAudioSessionPortDescription?>(value: AVAudioSession.sharedInstance().currentRoute.outputs.first)

	// MARK: - Inputs
	
	let togglePlayPause: AnyObserver<Void>
	let toggleShare: AnyObserver<Void>
	let toggleFanpage: AnyObserver<Void>
	
	// MARK: - Outputs
	
	let metadata: Observable<Metadata?>
	let playbackState: Observable<RadioPlayerPlaybackState>
	let state: Observable<RadioPlayerState>
	let isPlaying: Observable<Bool>
	let isLoading: Observable<Bool>
	let isFacebookButtonEnabled: Observable<Bool>
	let cover: Observable<Cover>

	let toggledPlayPause: Observable<Void>
	let openFanpage: Observable<FacebookData>
	let performShare: Observable<Metadata>
	let multipleRoutesDetected: Observable<Bool>
	let routeName: Observable<AVAudioSessionPortDescription?>
	
	// MARK: - Initilization

	required init(withServices services: Services) {
		radioPlayer = services.radioPlayer
		settings = services.settings
		coverLoader = services.coverLoader
		metadataLoader = services.metadataLoader
		nowPlayingInfoCenter = services.nowPlayingInfoCenter

		togglePlayPause = togglePlayPauseSubject.asObserver()
		toggleShare = toggleShareSubject.asObserver()
		toggleFanpage = toggleFanpageSubject.asObserver()

		metadata = metadataSubject.asObservable()
		playbackState = playbackStateSubject.asObservable()
		state = stateSubject.asObservable()
		isPlaying = isPlayingSubject.asObservable()
		isLoading = isLoadingSubject.asObservable()
		isFacebookButtonEnabled = isFacebookButtonEnabledSubject.asObservable()
		cover = coverSubject.asObservable()

		toggledPlayPause = toggledPlayPauseSubject.asObservable()
		openFanpage = openFanpageSubject.asObservable()
		performShare = performShareSubject.asObservable()
		multipleRoutesDetected = multipleRoutesDetectedSubject.asObservable()
		routeName = routeNameSubject.asObservable()

		radioPlayer.isAutoPlay = false
		
		bindObservables()
	}
	
	private func bindObservables() {
		NotificationCenter.default.rx
			.notification(.AVRouteDetectorMultipleRoutesDetectedDidChange)
			.compactMap { $0.object as? AVRouteDetector }
			.map { $0.multipleRoutesDetected }
			.bind(to: multipleRoutesDetectedSubject)
			.disposed(by: disposeBag)
		NotificationCenter.default.rx
			.notification(AVAudioSession.routeChangeNotification)
			.compactMap { _ in AVAudioSession.sharedInstance().currentRoute.outputs.first }
			.bind(to: routeNameSubject)
			.disposed(by: disposeBag)
		let togglePlayPause = togglePlayPauseSubject
			.share()
		togglePlayPause
			.bind(to: toggledPlayPauseSubject)
			.disposed(by: disposeBag)
		togglePlayPause
			.subscribe(onNext: { [unowned self] in
				self.radioPlayer.togglePlaying()
			})
			.disposed(by: disposeBag)
		toggleShareSubject
			.map { [unowned self] in try self.metadataSubject.value() }
			.compactMap { $0 }
			.bind(to: performShareSubject)
			.disposed(by: disposeBag)
		toggleFanpageSubject
			.map { [unowned self] in self.settings.facebook }
			.compactMap { $0 }
			.bind(to: openFanpageSubject)
			.disposed(by: disposeBag)
		let state = radioPlayer.state.share()
		let playbackState = radioPlayer.playbackState.share()
		state
			.bind(to: stateSubject)
			.disposed(by: disposeBag)
		playbackState
			.bind(to: playbackStateSubject)
			.disposed(by: disposeBag)
		Observable.combineLatest(state, playbackState)
			.map { $0.0 == .loading && $0.1 == .playing }
			.bind(to: isLoadingSubject)
			.disposed(by: disposeBag)
		Observable.just(settings.facebook != nil)
			.bind(to: isFacebookButtonEnabledSubject)
			.disposed(by: disposeBag)
		let radioMetadata = radioPlayer.metadata
			.map { (metadata: Metadata?) -> Metadata in
				if let metadata = metadata {
					return metadata
				}
				return MetadataItem(artist: "", title: "Loading metadata. Please wait.".localized)
			}
			.share()
		isPlayingSubject
			.bind(to: metadataLoader.isLoading)
			.disposed(by: disposeBag)
		let loadedMetadata = metadataLoader.metadata
			.share()
		Observable.of(radioMetadata, loadedMetadata)
			.merge()
			.bind(to: metadataSubject)
			.disposed(by: disposeBag)
		Observable.combineLatest(metadata.compactMap({ $0 }), cover)
			.map { NowPlayingInfo(artist: $0.artist, title: $0.title, artwork: $1.infoCenterImage) }
			.bind(to: nowPlayingInfoCenter.nowPlayingInfo)
			.disposed(by: disposeBag)
		metadata
			.compactMap { $0 }
			.distinctUntilChanged({ $0.artist == $1.artist && $0.title == $1.title })
			.map { $0.artist }
			.flatMapLatest { [unowned self] in self.coverLoader.loadCover(for: $0) }
			.bind(to: coverSubject)
			.disposed(by: disposeBag)
		radioPlayer.isPlaying
			.bind(to: isPlayingSubject)
			.disposed(by: disposeBag)
	}
}
