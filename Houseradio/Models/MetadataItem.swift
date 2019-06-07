//
//  MetadataItem.swift
//  Houseradio
//
//  Created by Pawel Rup on 14/04/2019.
//  Copyright © 2019 Pawel Rup. All rights reserved.
//

import Foundation
import RxRadioPlayer

struct MetadataItem: Metadata {
	let artist: String
	let title: String

	public init(artist: String, title: String) {
		self.artist = artist
		self.title = title
	}

	init(string: String) {
		let (artist, title) = MetadataItem.parse(string: string)
		self.artist = artist
		self.title = title
	}
}
