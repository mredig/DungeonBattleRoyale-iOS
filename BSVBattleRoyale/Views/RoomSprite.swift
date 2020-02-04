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

	let roomDimensions: CGFloat = 740
	var halfRoomDimensions: CGFloat { roomDimensions / 2 }
	var roomSize: CGSize { CGSize(width: roomDimensions, height: roomDimensions) }

	override init() {
		background = SKSpriteNode(imageNamed: "background")
		background.zPosition = -100
		background.anchorPoint = .zero
		background.position = CGPoint(x: -127.7, y: -127.7)
		super.init()
		addChild(background)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init coder not implemented")
	}

	private func updateSprites() {
		guard let room = room else { return }

		// remove all doors to create new ones
		[northDoor, southDoor, eastDoor, westDoor]
			.compactMap { $0 }
			.forEach { $0.removeFromParent() }

		if let northID = room.northRoomID {
			let newNorth = DoorSprite(id: northID)
			newNorth.position = CGPoint(x: halfRoomDimensions, y: roomDimensions)
			addChild(newNorth)
			northDoor = newNorth
		}

		if let southID = room.southRoomID {
			let south = DoorSprite(id: southID)
			south.position = CGPoint(x: halfRoomDimensions, y: 0)
			south.zRotation = CGFloat.pi / 180
			addChild(south)
			southDoor = south
		}

		if let eastID = room.eastRoomID {
			let east = DoorSprite(id: eastID)
			east.position = CGPoint(x: roomDimensions, y: halfRoomDimensions)
			east.zRotation = CGFloat.pi / 90
			addChild(east)
			eastDoor = east
		}

		if let westID = room.westRoomID {
			let west = DoorSprite(id: westID)
			west.position = CGPoint(x: 0, y: halfRoomDimensions)
			west.zRotation = CGFloat.pi / -90
			addChild(west)
			westDoor = west
		}
	}
}
