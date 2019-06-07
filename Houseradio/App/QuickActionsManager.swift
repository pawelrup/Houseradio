//
//  QuickActionsManager.swift
//  Houseradio
//
//  Created by Pawel Rup on 16/10/2018.
//  Copyright © 2018 Pawel Rup. All rights reserved.
//

import UIKit
import RxSwift
import RxRadioPlayer

private let kPlayShortcutItem = "kPlayShortcutItem"
private let kPauseShortcutItem = "kPauseShortcutItem"

class QuickActionsManager {

	private let radioPlayer: RadioPlayer
	private let play = PublishSubject<Void>()
	private let disposeBag = DisposeBag()
	
	init(radioPlayer: RadioPlayer) {
		self.radioPlayer = radioPlayer

		bindObservables()
	}
	
	private func bindObservables() {
		let isPlaying = radioPlayer.isPlaying.share(replay: 1)
		let metadata = radioPlayer.metadata
			.share(replay: 1)
			.compactMap { $0 }
		Observable.combineLatest(isPlaying, metadata)
			.distinctUntilChanged({ $0.0 == $1.0 && $0.1.artist == $1.1.artist && $0.1.title == $1.1.title })
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] (isPlaying: Bool, metadata: Metadata) in
				if isPlaying {
					self?.setPauseShortcut(with: metadata.title)
				} else {
					self?.setPlayShortcut()
				}
			})
			.disposed(by: disposeBag)
		Observable.combineLatest(radioPlayer.state, play)
			.map { $0.0 }
			.skipWhile { $0 != .loading }
			.subscribe(onNext: { [unowned self] _ in
				self.radioPlayer.play()
			})
			.disposed(by: disposeBag)
	}
	
	func setPlayShortcut() {
		let playShortcut = UIMutableApplicationShortcutItem(type: kPlayShortcutItem, localizedTitle: "Play".localized, localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .play))
		UIApplication.shared.shortcutItems = [playShortcut]
	}
	
	func setPauseShortcut(with title: String? = nil) {
		let pauseShortcut = UIMutableApplicationShortcutItem(type: kPauseShortcutItem, localizedTitle: "Pause".localized, localizedSubtitle: title, icon: UIApplicationShortcutIcon(type: .pause))
		UIApplication.shared.shortcutItems = [pauseShortcut]
	}
	
	func performAction(for shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		switch shortcutItem.type {
		case kPlayShortcutItem:
			play.onNext(())
			completionHandler(true)
		case kPauseShortcutItem:
			radioPlayer.pause()
			completionHandler(true)
		default:
			completionHandler(false)
		}
	}
}
