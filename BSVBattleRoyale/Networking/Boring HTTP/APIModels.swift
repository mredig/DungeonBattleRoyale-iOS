//
//  APIModels.swift
//  BSVBattleRoyale
//
//  Created by Michael Redig on 2/5/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import Foundation
import CoreGraphics


struct PlayerInit: Codable {
	let playerID: String
	let roomID: Int
	let spawnLocation: CGPoint
	let avatar: Int
	let username: String
}


struct PlayerMove: Codable {
	let currentRoom: Int
	let spawnLocation: CGPoint
}


struct PlayerState {
	var playerID: String
	var spawnLocation: CGPoint
}

struct PositionPulseUpdate: Codable {
	let position: CGPoint
	let destination: CGPoint
}

struct PlayerInfo: Codable {
	let avatar: Int
	let username: String
}
