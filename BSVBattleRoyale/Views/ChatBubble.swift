//
//  ChatBubble.swift
//  BSVBattleRoyale
//
//  Created by Michael Redig on 2/6/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import SpriteKit

class ChatBubble: SKSpriteNode {
	private let textNode = SKLabelNode(text: "chat test")
	private let box = SKSpriteNode(color: .white, size: .zero)
	private let border = SKSpriteNode(color: .black, size: .zero)

	init() {
		super.init(texture: nil, color: .clear, size: .zero)
		textNode.fontSize = 15
		textNode.verticalAlignmentMode = .center
		textNode.fontName = "Verdana-Bold"

		border.zPosition = 50
		box.zPosition = 50.001
		textNode.zPosition = 50.002
		textNode.color = .black
		textNode.fontColor = .black
		addChild(border)
		addChild(box)
		addChild(textNode)

		alpha = 0
		anchorPoint = CGPoint(x: 0.5, y: 0)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init coder not implemented")
	}

	var text: String {
		get { textNode.text ?? "" }
		set {
			textNode.text = newValue
			updateText()
		}
	}

	private func updateText() {
		guard !text.isEmpty else { return }
		let textSize = textNode.calculateAccumulatedFrame().size
		let boxSize = textSize + 5
		let borderSize = boxSize + 5

		box.size = boxSize
		border.size = borderSize
		alpha = 1
		let fade = SKAction.sequence([
			SKAction.wait(forDuration: 5),
			SKAction.fadeOut(withDuration: 1)
		])

		run(fade, withKey: "fade")
	}

}
