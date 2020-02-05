//
//  RoomScene.swift
//  BSVBattleRoyale
//
//  Created by Michael Redig on 2/4/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import SpriteKit

class RoomScene: SKScene {

	let background = RoomSprite()

	var currentPlayer: Player?

	override func didMove(to view: SKView) {
		super.didMove(to: view)
		setupScene()
	}

	func setupScene() {
		addChild(background)

		let newPlayer = Player(avatar: .yellowMonster)
		newPlayer.position = CGPoint.zero
		addChild(newPlayer)
		currentPlayer = newPlayer

		let playerCamera = SKCameraNode()
		currentPlayer?.addChild(playerCamera)
		camera = playerCamera

		physicsWorld.gravity = CGVector.zero
		physicsWorld.contactDelegate = self
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		for touch in touches {
			let location = touch.location(in: self)

			currentPlayer?.move(to: location, duration: -250)
		}
	}

	override func update(_ currentTime: TimeInterval) {
		super.update(currentTime)

		// send player position
	}
}

extension RoomScene: SKPhysicsContactDelegate {

	func didBegin(_ contact: SKPhysicsContact) {
		let bodies = Set([contact.bodyB, contact.bodyA])
		let nodes = Set(bodies.compactMap { $0.node })

		if let currentPlayer = currentPlayer {
			if nodes.contains(currentPlayer) && nodes.contains(background) {
				currentPlayer.stopMove()
			}
		}
	}
}
