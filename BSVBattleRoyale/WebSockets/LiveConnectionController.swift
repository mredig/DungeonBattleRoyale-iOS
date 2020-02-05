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

	init?(playerID: String) {
		guard let url = URL(string: "ws://localhost:8000/ws/rooms/\(playerID)") else { return nil }

		webSocketConnection = WebSocketTaskConnection(url: url)
		webSocketConnection.delegate = self
		webSocketConnection.connect()
	}

	func updatePlayerPosition(_ position: CGPoint) {
		guard let packet = WSPacket(type: .positionUpdate, content: ["position": [position.x, position.y]]).json else { return }
		webSocketConnection.send(text: packet)
	}
}

extension LiveConnectionController: WebSocketConnectionDelegate {

	func onConnected(connection: WebSocketConnection) {
		print("connected!")
	}

	func onDisconnected(connection: WebSocketConnection, error: Error?) {
		print("disconnected: \(error!)")
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
