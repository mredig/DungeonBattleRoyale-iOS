//
//  LiveConnectionController.swift
//  BSVBattleRoyale
//
//  Created by Michael Redig on 2/4/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import Foundation
import CoreGraphics

class LiveConnectionController {
	var webSocketConnection: WebSocketConnection

	private var connected = false

	init?(playerID: String) {
		guard let url = backendWSURL?
			.appendingPathComponent("ws")
			.appendingPathComponent("rooms")
			.appendingPathComponent(playerID) else { return nil }

		webSocketConnection = WebSocketTaskConnection(url: url)
		webSocketConnection.delegate = self
		webSocketConnection.connect()
	}


	private var lastSend = TimeInterval(0)
	let sendDelta: TimeInterval = 1/15
	func updatePlayerPosition(_ position: CGPoint) {
		guard connected else { return }
		let currentTime = CFAbsoluteTimeGetCurrent()
		guard let packet = WSPacket(type: .positionUpdate, content: ["position": [position.x, position.y]]).json,
		currentTime > lastSend + sendDelta else { return }
		webSocketConnection.send(text: packet)
		lastSend = currentTime
	}

	func disconnect() {
		webSocketConnection.disconnect()
	}
}

extension LiveConnectionController: WebSocketConnectionDelegate {

	func onConnected(connection: WebSocketConnection) {
		print("connected!")
		connected = true
	}

	func onDisconnected(connection: WebSocketConnection, error: Error?) {
        print("disconnected: \(String(describing: error))")
		connected = false
	}

	func onError(connection: WebSocketConnection, error: Error) {
		print("error: \(error)")
	}

	func onMessage(connection: WebSocketConnection, text: String) {
		print("got text: \(text)")
	}

	func onMessage(connection: WebSocketConnection, data: Data) {
		print("got data: \(data)")
	}
}
