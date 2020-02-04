//
//  Room.swift
//  BSVBattleRoyale
//
//  Created by Michael Redig on 2/4/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import SpriteKit

class RoomSprite: SKNode {
	var northDoor: DoorSprite?
	var southDoor: DoorSprite?
	var eastDoor: DoorSprite?
	var westDoor: DoorSprite?
	let background: SKSpriteNode

	var room: Room? {
		didSet {
			updateSprites()
		}
	}

	override init() {
		background = SKSpriteNode(imageNamed: "background")
		background.zPosition = -100
		background.position = CGPoint(x: -127.7, y: -127.7)
		super.init()
		addChild(background)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init coder not implemented")
	}

	private func updateSprites() {

	}
}
