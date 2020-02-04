//
//  RoomScene.swift
//  BSVBattleRoyale
//
//  Created by Michael Redig on 2/4/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import SpriteKit

class RoomScene: SKScene {

	override func didMove(to view: SKView) {
		super.didMove(to: view)
		setupScene()
	}

	func setupScene() {
		let background = RoomSprite()
		addChild(background)
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
