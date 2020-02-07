//
//  Room.swift
//  MapVis
//
//  Created by Michael Redig on 2/1/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import Foundation
import CoreGraphics

class RoomCollection: Codable {
	let rooms: [Int: Room]
	let roomCoordinates: Set<CGPoint>
	let spawnRoom: Int
}

