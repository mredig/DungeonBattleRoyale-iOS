//
//  Player.swift
//  BSVBattleRoyale
//
//  Created by Michael Redig on 2/4/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import SpriteKit

enum PlayerDirection {
	case left
	case right
}

enum Avatar {
	case yellowMonster
}

enum AnimationTitle: String {
	case idle = "Idle"
	case attack = "Attack"
	case die = "Die"
	case jump = "Jump"
	case run = "Run"
	case walk = "Walk"
}

class Player: SKNode {
	var direction: PlayerDirection = .right

	let playerSprite: SKSpriteNode
	let avatar: Avatar

	init(avatar: Avatar) {
		self.avatar = avatar
		let idleAnimation = Player.animationTextures(for: avatar, animationTitle: AnimationTitle.idle)
		playerSprite = SKSpriteNode(texture: idleAnimation.first)
		playerSprite.run(Player.animationAction(with: idleAnimation))
		playerSprite.anchorPoint = CGPoint(x: 0.5, y: 0)

		super.init()
		addChild(playerSprite)
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init coder not implemented")
	}

}

extension Player {
	static let character1Atlas = SKTextureAtlas(named: "YellowMonster")

	static func animationTextures(for avatar: Avatar, animationTitle: AnimationTitle) -> [SKTexture] {
		let atlas: SKTextureAtlas
		switch avatar {
		case .yellowMonster:
			atlas = character1Atlas
		}
		return atlas.textureNames
			.filter { $0.hasPrefix(animationTitle.rawValue) }
			.sorted()
			.map { atlas.textureNamed($0) }
	}

	static func animationAction(for avatar: Avatar, animationTitle: AnimationTitle) -> SKAction {
		animationAction(with: animationTextures(for: avatar, animationTitle: animationTitle))
	}

	static func animationAction(with textures: [SKTexture]) -> SKAction {
		let animation = SKAction.animate(with: textures, timePerFrame: 1.0 / 12.0)
		return SKAction.repeatForever(animation)
	}
}
