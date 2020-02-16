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
	let username: String
	let roomID: Int
	let spawnLocation: CGPoint
	let avatar: Int
}


struct PlayerMove: Codable {
	let currentRoom: Int
	let spawnLocation: CGPoint
	let otherPlayersInRoom: [String]
}


struct PlayerState {
	var playerID: String
	var spawnLocation: CGPoint
}

struct PositionPulseUpdate: Codable {
	let position: CGPoint
	let destination: CGPoint
	let playerID: String?

	init(position: CGPoint, destination: CGPoint, playerID: String? = nil) {
		self.position = position
		self.destination = destination
		self.playerID = playerID
	}

	/// returns a new PositionPulseUpdate, but with the playerID value populated with the passed in value
	func setting(playerID: String) -> PositionPulseUpdate {
		PositionPulseUpdate(position: position, destination: destination, playerID: playerID)
	}
}

struct ChatMessage: Codable {
	let message: String
	let playerID: String
}

struct PlayerInfo: Codable {
	let avatar: Int
	let username: String
}

struct PlayerAttack: Codable {
	let attacker: String
	let hitPlayers: [String]
}
