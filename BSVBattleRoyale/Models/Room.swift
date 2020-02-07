//
//  Room.swift
//  MapVis
//
//  Created by Michael Redig on 2/1/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import Foundation
import CoreGraphics

struct Room: Codable {
	let name: String
	let position: CGPoint
	let id: String
	let northRoomID: String?
	let southRoomID: String?
	let eastRoomID: String?
	let westRoomID: String?

	enum CodingKeys: String, CodingKey {
		case name
		case position
		case id
		case northRoomID = "north"
		case southRoomID = "south"
		case eastRoomID = "east"
		case westRoomID = "west"
	}
}

