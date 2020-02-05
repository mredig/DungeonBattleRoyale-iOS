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

enum AnimationTitle: String, CaseIterable {
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

	let animationPriority: Stack<AnimationTitle> = {
		let stack = Stack<AnimationTitle>()
		stack.push(.walk)
		return stack
	}()

	init(avatar: Avatar) {
		self.avatar = avatar
		let idleAnimation = Player.animationTextures(for: avatar, animationTitle: AnimationTitle.idle)
		playerSprite = SKSpriteNode(texture: idleAnimation.first)

		super.init()
		addChild(playerSprite)

		physicsBody = SKPhysicsBody(circleOfRadius: playerSprite.size.width / 3)

		// crappy animation priority system - probably scrap this
		let animationPriorityRunner = SKAction.customAction(withDuration: 1/15) { [weak self] node, elapsed in
			guard let self = self else { return }
			guard let currentAnimationPriority = self.animationPriority.peek() else { return }
			if node.action(forKey: "animation\(currentAnimationPriority.rawValue)") == nil {
				for animation in AnimationTitle.allCases {
					node.removeAction(forKey: "animation\(animation.rawValue)")
				}
				node.run(Player.animationAction(for: avatar, animationTitle: currentAnimationPriority), withKey: "animation\(currentAnimationPriority.rawValue)")
			}
		}
		let forever = SKAction.repeatForever(animationPriorityRunner)
		playerSprite.run(forever, withKey: "animationPriority")
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

		run(moveAction, withKey: Player.moveKey)
	}
}

extension Player {
	private static let animationKey = "animation"
	private static let moveKey = "move"

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
