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
		// FIXME: For testing
		background.position = CGPoint(x: 128, y: 128)
		addChild(SKSpriteNode(color: .red, size: CGSize(width: 5, height: 5)))

		let newPlayer = Player(avatar: .yellowMonster)
		newPlayer.position = CGPoint(x: 207, y: 207)
		addChild(newPlayer)
		currentPlayer = newPlayer
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		for touch in touches {
			let location = touch.location(in: self)
			print("touched at \(location)")
		}
	}

	override func update(_ currentTime: TimeInterval) {
		super.update(currentTime)
	}
}
