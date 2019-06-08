//
//  RemoteCommandCenter.swift
//  Houseradio
//
//  Created by Pawel Rup on 08/06/2019.
//  Copyright © 2019 Pawel Rup. All rights reserved.
//

import Foundation
import MediaPlayer
import RxRadioPlayer

class RemoteCommandCenter {

	private weak var radioPlayer: RadioPlayer?

	init(radioPlayer: RadioPlayer) {
		self.radioPlayer = radioPlayer
	}

	deinit {
		UIApplication.shared.endReceivingRemoteControlEvents()
		let remoteCommandCenter = MPRemoteCommandCenter.shared()
		remoteCommandCenter.togglePlayPauseCommand.removeTarget(self)
		remoteCommandCenter.playCommand.removeTarget(self)
		remoteCommandCenter.pauseCommand.removeTarget(self)
		remoteCommandCenter.stopCommand.removeTarget(self)
	}

	func setupRemoteCommandCenter() {
		UIApplication.shared.beginReceivingRemoteControlEvents()
		let remoteCommandCenter = MPRemoteCommandCenter.shared()
		remoteCommandCenter.togglePlayPauseCommand.isEnabled = true
		remoteCommandCenter.togglePlayPauseCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
			self?.radioPlayer?.togglePlaying()
			return .success
		}
		remoteCommandCenter.playCommand.isEnabled = true
		remoteCommandCenter.playCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
			self?.radioPlayer?.play()
			return .success
		}
		remoteCommandCenter.pauseCommand.isEnabled = true
		remoteCommandCenter.pauseCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
			self?.radioPlayer?.pause()
			return .success
		}
		remoteCommandCenter.stopCommand.isEnabled = true
		remoteCommandCenter.stopCommand.addTarget { [weak self] _ -> MPRemoteCommandHandlerStatus in
			self?.radioPlayer?.stop()
			return .success
		}
	}
}
