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
		newPlayer.position = CGPoint(x: 207, y: 207)
		addChild(newPlayer)
		currentPlayer = newPlayer

		let playerCamera = SKCameraNode()
		currentPlayer?.addChild(playerCamera)
		camera = playerCamera
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		for touch in touches {
			let location = touch.location(in: self)

			let moveAction = SKAction.move(to: location, duration: 2)

			currentPlayer?.run(moveAction, withKey: "move")
		}
	}

	override func update(_ currentTime: TimeInterval) {
		super.update(currentTime)
	}
}
