//
//  LiveConnectionController.swift
//  BSVBattleRoyale
//
//  Created by Michael Redig on 2/4/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import Foundation
import CoreGraphics

protocol LiveConnectionControllerDelegate: AnyObject {
	func otherPlayersUpdated(on controller: LiveConnectionController, updatedPositions: [String: OtherPlayerUpdate])
}

class LiveConnectionController {
	var webSocketConnection: WebSocketConnection

	private var connected = false
	weak var delegate: LiveConnectionControllerDelegate?

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
//		print("got text: \(text)")
		guard let jsonData = text.data(using: .utf8) else { return }
		do {
			let jsonObj = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]

			guard let messageType = jsonObj?["messageType"] as? String else { return }
			guard let dataObj = jsonObj?["data"] else { return }

			switch messageType {
			case "playerPositions":
				distributePositionData(data: dataObj)
			default:
				break
			}
		} catch {
			NSLog("Invalid json: \(text) (\(error))")
		}
	}

	func onMessage(connection: WebSocketConnection, data: Data) {
		print("got data: \(data)")
	}

	private func distributePositionData(data: Any) {
		guard let dict = data as? [String: [String: [CGFloat]]] else { return }

		var otherPlayers = [String: OtherPlayerUpdate]()
		for (playerID, positionDict) in dict {
			guard let positions = positionDict["position"], positions.count == 2 else { continue }
			let position = CGPoint(x: positions[0], y: positions[1])
			otherPlayers[playerID] = OtherPlayerUpdate(position: position)
		}

		delegate?.otherPlayersUpdated(on: self, updatedPositions: otherPlayers)
	}

}
