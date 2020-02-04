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
		addChild(doorSprite)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init coder not implemented")
	}
}
