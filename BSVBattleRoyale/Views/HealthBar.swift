//
//  HealthBar.swift
//  DungeonBattleRoyale
//
//  Created by Michael Redig on 2/23/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import SpriteKit

class HealthBar: SKNode {
	var maxHP: Int { didSet { updateHealth() } }
	var currentHP: Int { didSet { updateHealth() } }

	let border: SKSpriteNode
	let maxHealthBar: SKSpriteNode
	let currentHealthBar: SKSpriteNode
	var borderWidth: CGFloat { didSet { updateSize() } }
	var size: CGSize { didSet { updateSize() } }
	var anchorPoint = CGPoint(x: 0.5, y: 0) { didSet { updatePositions() } }

	init(hp: Int, size: CGSize, borderWidth: CGFloat) {
		maxHP = hp
		currentHP = hp
		self.borderWidth = borderWidth
		self.size = size

		border = SKSpriteNode(color: .black, size: size)
		maxHealthBar = SKSpriteNode(color: .red, size: size - (borderWidth * 2))
		currentHealthBar = SKSpriteNode(color: .green, size: size - (borderWidth * 2))
		super.init()
		addChild(border)
		border.addChild(maxHealthBar)
		maxHealthBar.addChild(currentHealthBar)
		maxHealthBar.position = CGPoint(scalar: borderWidth)
		[maxHealthBar, currentHealthBar, border].forEach { $0.anchorPoint = .zero }
		updateSize()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init coder not implemented")
	}

	private func updateSize() {
		border.size = size
		maxHealthBar.size = size - (borderWidth * 2)
		currentHealthBar.size = size - (borderWidth * 2)
		updatePositions()
	}

	private func updatePositions() {
		border.position.x = -anchorPoint.x * border.size.width
		border.position.y = -anchorPoint.y * border.size.height
	}

	private func updateHealth() {
		guard currentHP >= 0 else { currentHP = 0; return }
		let percent = CGFloat(currentHP) / CGFloat(maxHP)
		currentHealthBar.xScale = percent
	}
}
