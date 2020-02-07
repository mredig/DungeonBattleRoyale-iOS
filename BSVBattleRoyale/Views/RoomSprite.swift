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
	private let doorWidth: CGFloat = 90
	private var hDoorWidth: CGFloat { doorWidth / 2 }
	private let doorHeight: CGFloat = 128
	private var hDoorHeight: CGFloat { doorHeight / 2 }

	override init() {
		background = SKSpriteNode(imageNamed: "background")
		background.zPosition = -100
		background.anchorPoint = .zero
		background.position = CGPoint(x: -127.7, y: -127.7)
		super.init()
		addChild(background)

		let chainPath = CGMutablePath()
		chainPath.move(to: .zero)
		chainPath.addLine(to: CGPoint(x: 0, y: halfRoomDimensions - hDoorWidth))
		chainPath.addLine(to: CGPoint(x: -doorHeight, y: halfRoomDimensions - hDoorWidth))
		chainPath.addLine(to: CGPoint(x: -doorHeight, y: halfRoomDimensions + hDoorWidth))
		chainPath.addLine(to: CGPoint(x: 0, y: halfRoomDimensions + hDoorWidth))
		chainPath.addLine(to: CGPoint(x: 0, y: roomDimensions))
		chainPath.addLine(to: CGPoint(x: halfRoomDimensions - hDoorWidth, y: roomDimensions))
		chainPath.addLine(to: CGPoint(x: halfRoomDimensions - hDoorWidth, y: roomDimensions + doorHeight))
		chainPath.addLine(to: CGPoint(x: halfRoomDimensions + hDoorWidth, y: roomDimensions + doorHeight))
		chainPath.addLine(to: CGPoint(x: halfRoomDimensions + hDoorWidth, y: roomDimensions))
		chainPath.addLine(to: CGPoint(x: roomDimensions, y: roomDimensions))
		chainPath.addLine(to: CGPoint(x: roomDimensions, y: halfRoomDimensions + hDoorWidth))
		chainPath.addLine(to: CGPoint(x: roomDimensions + doorHeight, y: halfRoomDimensions + hDoorWidth))
		chainPath.addLine(to: CGPoint(x: roomDimensions + doorHeight, y: halfRoomDimensions - hDoorWidth))
		chainPath.addLine(to: CGPoint(x: roomDimensions, y: halfRoomDimensions - hDoorWidth))
		chainPath.addLine(to: CGPoint(x: roomDimensions, y: 0))
		chainPath.addLine(to: CGPoint(x: halfRoomDimensions + hDoorWidth, y: 0))
		chainPath.addLine(to: CGPoint(x: halfRoomDimensions + hDoorWidth, y: -doorHeight))
		chainPath.addLine(to: CGPoint(x: halfRoomDimensions - hDoorWidth, y: -doorHeight))
		chainPath.addLine(to: CGPoint(x: halfRoomDimensions - hDoorWidth, y: 0))

		physicsBody = SKPhysicsBody(edgeLoopFrom: chainPath)
		physicsBody?.categoryBitMask = wallBitmask
		physicsBody?.contactTestBitMask = playerBitmask | wallBitmask
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
			south.zRotationDegrees = 180
			addChild(south)
			southDoor = south
		}

		if let eastID = room.eastRoomID {
			let east = DoorSprite(id: eastID)
			east.position = CGPoint(x: roomDimensions, y: halfRoomDimensions)
			east.zRotationDegrees = -90
			addChild(east)
			eastDoor = east
		}

		if let westID = room.westRoomID {
			let west = DoorSprite(id: westID)
			west.position = CGPoint(x: 0, y: halfRoomDimensions)
			west.zRotationDegrees = 90
			addChild(west)
			westDoor = west
		}
	}
}
