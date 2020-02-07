//
//  DoorSprite.swift
//  BSVBattleRoyale
//
//  Created by Michael Redig on 2/4/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import SpriteKit

class DoorSprite: SKNode {
	let doorSprite: SKSpriteNode

	let id: String

	init(id: String) {
		doorSprite = SKSpriteNode(imageNamed: "door")
		doorSprite.zPosition = -10
		doorSprite.anchorPoint = CGPoint(x: 0.5, y: 0)


		self.id = id
		super.init()
		physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: -doorSprite.size.width / 2,
														 y: doorSprite.size.height / 2,
														 width: doorSprite.size.width,
														 height: doorSprite.size.height / 2))
		physicsBody?.categoryBitMask = doorBitmask
		physicsBody?.contactTestBitMask = playerBitmask
		addChild(doorSprite)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init coder not implemented")
	}
}
