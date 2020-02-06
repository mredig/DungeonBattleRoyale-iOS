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

enum Avatar: Int {
	case yellowMonster
	case pinkMonster
	case purpleMonster
	case blueMonster
	case greenMonster
}

enum AnimationTitle: String, CaseIterable {
	// ordered by priority, lowest to highest
	case idle = "Idle"
	case walk = "Walk"
	case run = "Run"
	case attack = "Attack"
	case jump = "Jump"
	case die = "Die"
}

class Player: SKNode {
	var direction: PlayerDirection = .right {
		didSet {
			updateFacing()
		}
	}

	private let playerSprite: SKSpriteNode
	private let nameSprite: SKLabelNode
	var avatar: Avatar {
		didSet {

		}
	}
	let id: String
	var username: String {
		get { nameSprite.text ?? "" }
		set { nameSprite.text = newValue }
	}

	var currentAnimations = Set([AnimationTitle.idle])
	var animationPriority: AnimationTitle {
		for animation in AnimationTitle.allCases.reversed() {
			if currentAnimations.contains(animation) {
				return animation
			}
		}
		return .idle
	}
	var animationMaintainer: Timer?

	var destination: CGPoint = .zero

	init(avatar: Avatar, id: String, username: String = "Player \(Int.random(in: 0...500))") {
		self.avatar = avatar
		let idleAnimation = Player.animationTextures(for: avatar, animationTitle: AnimationTitle.idle)
		playerSprite = SKSpriteNode(texture: idleAnimation.first)
		self.id = id

		nameSprite = SKLabelNode(text: username)
		nameSprite.color = UIColor(hue: CGFloat.random(in: 0...1), saturation: CGFloat.random(in: 0.6...1), brightness: CGFloat.random(in: 0.7...1), alpha: 1)
		nameSprite.horizontalAlignmentMode = .center
		nameSprite.verticalAlignmentMode = .center
		nameSprite.position = CGPoint(x: 0, y: playerSprite.size.height / 2)
		nameSprite.fontSize = 20
		super.init()
		addChild(playerSprite)
		addChild(nameSprite)

		physicsBody = SKPhysicsBody(circleOfRadius: playerSprite.size.width / 3)
		physicsBody?.categoryBitMask = playerBitmask
		physicsBody?.contactTestBitMask = wallBitmask | doorBitmask // | playerBitmask
		physicsBody?.collisionBitMask = wallBitmask | doorBitmask

		animationMaintainer = Timer.scheduledTimer(withTimeInterval: 1/15, repeats: true, block: { [weak self] _ in
			self?.updateCurrentAnimation()
		})
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init coder not implemented")
	}

	override func removeFromParent() {
		animationMaintainer?.invalidate()
		animationMaintainer = nil
		super.removeFromParent()
	}

	private func updateFacing() {
		playerSprite.xScale = direction == .left ? 1.0 : -1.0
	}

	private func updateAvatar() {
		AnimationTitle.allCases.forEach { playerSprite.removeAction(forKey: "animation\($0.rawValue)") }
		updateCurrentAnimation()
	}

	private func updateCurrentAnimation() {
		if playerSprite.action(forKey: "animation\(animationPriority.rawValue)") == nil {
			for animation in AnimationTitle.allCases {
				playerSprite.removeAction(forKey: "animation\(animation.rawValue)")
			}
			playerSprite.run(Player.animationAction(for: avatar, animationTitle: animationPriority), withKey: "animation\(animationPriority.rawValue)")
		}
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
		let seq = SKAction.sequence([
			moveAction,
			SKAction.run {
				self.currentAnimations.remove(.walk)
			}
		])
		currentAnimations.insert(.walk)

		run(seq, withKey: Player.moveKey)
	}

	func stopMove() {
		removeAction(forKey: Player.moveKey)
	}
}

extension Player {
	private static let animationKey = "animation"
	private static let moveKey = "move"

	static let yellowAtlas = SKTextureAtlas(named: "YellowMonster")
	static let pinkAtlas = SKTextureAtlas(named: "PinkMonster")
	static let purpleAtlas = SKTextureAtlas(named: "PurpleMonster")
	static let greenAtlas = SKTextureAtlas(named: "GreenMonster")
	static let blueAtlas = SKTextureAtlas(named: "BlueMonster")

	static func animationTextures(for avatar: Avatar, animationTitle: AnimationTitle) -> [SKTexture] {
		let atlas: SKTextureAtlas
		switch avatar {
		case .yellowMonster:
			atlas = yellowAtlas
		case .blueMonster:
			atlas = blueAtlas
		case .greenMonster:
			atlas = greenAtlas
		case .purpleMonster:
			atlas = purpleAtlas
		case .pinkMonster:
			atlas = pinkAtlas
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
