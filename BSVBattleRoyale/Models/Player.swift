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
	var direction: PlayerDirection = .right {
		didSet {
			updateFacing()
		}
	}

	let playerSprite: SKSpriteNode
	let avatar: Avatar

	init(avatar: Avatar) {
		self.avatar = avatar
		let idleAnimation = Player.animationTextures(for: avatar, animationTitle: AnimationTitle.idle)
		playerSprite = SKSpriteNode(texture: idleAnimation.first)
		playerSprite.run(Player.animationAction(with: idleAnimation))

		super.init()
		addChild(playerSprite)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init coder not implemented")
	}

	private func updateFacing() {
		playerSprite.xScale = direction == .left ? 1.0 : -1.0
	}

	/// if duration is >= 0, moves in `duration` seconds. If less than zero, moves at speed of `duration` points per second
	func move(to location: CGPoint, duration: CGFloat) {

		direction = location.x > position.x ? .right : .left

		let distance = position.distance(to: location)

		let time: CGFloat
		if duration >= 0 {
			time = duration
		} else {
			time = distance / -duration
		}
		let moveAction = SKAction.move(to: location, duration: Double(time))
		run(moveAction, withKey: "move")
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
		let names = atlas.textureNames
			.filter { $0.hasPrefix(animationTitle.rawValue) && !$0.contains("@2x") && !$0.contains("@3x") }
		let sorted = names.map{ ($0 as NSString).deletingPathExtension }.sorted()
		let textures = sorted.map { atlas.textureNamed($0) }
		return textures
	}

	static func animationAction(for avatar: Avatar, animationTitle: AnimationTitle) -> SKAction {
		animationAction(with: animationTextures(for: avatar, animationTitle: animationTitle))
	}

	static func animationAction(with textures: [SKTexture]) -> SKAction {
		let animation = SKAction.animate(with: textures, timePerFrame: 1.0 / 12.0)
		return SKAction.repeatForever(animation)
	}
}
