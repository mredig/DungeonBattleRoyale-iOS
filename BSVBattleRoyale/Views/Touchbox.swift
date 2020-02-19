//
//  Touchbox.swift
//  DungeonBattleRoyale
//
//  Created by Michael Redig on 2/18/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import Foundation
import SpriteKit

protocol TouchBoxDelegate: AnyObject {
	func touchBegan(on touchBox: TouchBox, at location: CGPoint)
	func touchMoved(on touchBox: TouchBox, at location: CGPoint)
	func touchEnded(on touchBox: TouchBox, at location: CGPoint)
	func touchCancelled(on touchBox: TouchBox, at location: CGPoint)
}

extension TouchBoxDelegate {
	func touchBegan(on touchBox: TouchBox, at location: CGPoint) {}
	func touchMoved(on touchBox: TouchBox, at location: CGPoint) {}
	func touchEnded(on touchBox: TouchBox, at location: CGPoint) {}
	func touchCancelled(on touchBox: TouchBox, at location: CGPoint) {}
}

class TouchBox: SKNode {

	weak var delegate: TouchBoxDelegate?
	private let geometry: SKSpriteNode
	var size: CGSize {
		get { geometry.size }
		set { geometry.size = newValue }
	}

	var color: UIColor {
		get { geometry.color }
		set { geometry.color = newValue }
	}

	init(size: CGSize, color: UIColor) {
		self.geometry = SKSpriteNode(color: color, size: size)
		super.init()
		addChild(geometry)
		isUserInteractionEnabled = true
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init coder not implemented")
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		for touch in touches {
			let location = touch.location(in: self)
			delegate?.touchBegan(on: self, at: location)
		}
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)
		for touch in touches {
			let location = touch.location(in: self)
			delegate?.touchMoved(on: self, at: location)
		}
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		for touch in touches {
			let location = touch.location(in: self)
			delegate?.touchEnded(on: self, at: location)
		}
	}

	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesCancelled(touches, with: event)
		for touch in touches {
			let location = touch.location(in: self)
			delegate?.touchCancelled(on: self, at: location)
		}
	}
}
