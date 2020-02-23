//
//  APIModels.swift
//  BSVBattleRoyale
//
//  Created by Michael Redig on 2/5/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import Foundation
import CoreGraphics

/// makes keeping vapor code and this code synced easier
fileprivate typealias Content = Codable

struct PlayerInit: Content {
	let playerID: String
	let username: String
	let roomID: Int
	let spawnLocation: CGPoint
	let avatar: Int
}


struct PlayerMove: Content {
	let currentRoom: Int
	let spawnLocation: CGPoint
	let otherPlayersInRoom: [String]
}


struct PlayerState {
	var playerID: String
	var spawnLocation: CGPoint
}

struct PositionPulseUpdate: Content {
	let position: CGPoint
	let trajectory: CGVector
	let playerID: String?

	init(position: CGPoint, trajectory: CGVector, playerID: String? = nil) {
		self.position = position
		self.trajectory = trajectory
		self.playerID = playerID
	}

	/// returns a new PositionPulseUpdate, but with the playerID value populated with the passed in value
	func setting(playerID: String) -> PositionPulseUpdate {
		PositionPulseUpdate(position: position, trajectory: trajectory, playerID: playerID)
	}
}

struct ChatMessage: Content {
	let message: String
	let playerID: String
}

struct PlayerInfo: Content {
	let avatar: Int
	let username: String
}

struct PlayerAttack: Content {
	let attacker: String
	let hits: [AttackContact]
}

struct AttackContact: Content {
	let victim: String
	let vector: CGVector
	let strength: CGFloat
}

struct LatencyPing: Content, Hashable {
	let timestamp: Date
}
