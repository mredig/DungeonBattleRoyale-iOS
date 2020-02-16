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
}

protocol LiveInteractionDelegate: AnyObject {
	func otherPlayersUpdated(on controller: LiveConnectionController, updatedPositions: [String: PositionPulseUpdate])
	func chatReceived(on controller: LiveConnectionController, message: String, playerID: String)
	func attackBroadcastReceived(on controller: LiveConnectionController, from playerID: String, hitPlayers: [String])
}

class LiveConnectionController {
	var webSocketConnection: WebSocketConnection

	private var connected = false
	weak var delegate: LiveConnectionControllerDelegate?
	weak var liveInteractionDelegate: LiveInteractionDelegate?

	init?(playerID: String) {
		guard let url = backendWSURL?
			.appendingPathComponent("ws")
			.appendingPathComponent("rooms")
			.appendingPathComponent(playerID) else { return nil }

		webSocketConnection = WebSocketTaskConnection(url: url)
		webSocketConnection.delegate = self
		webSocketConnection.connect()
	}

	func updatePlayerPosition(_ position: CGPoint, destination: CGPoint) {
		guard connected else { return }
		guard let packet = WSPacket(type: .positionUpdate, content: ["position": [position.x, position.y], "destination": [destination.x, destination.y]]).json
			else { return }
		webSocketConnection.send(text: packet)
	}

	private var lastSend = TimeInterval(0)
	let sendDelta: TimeInterval = 1/3
	func sendPositionPulse(_ position: CGPoint, destination: CGPoint) {
		guard connected else { return }
		let currentTime = CFAbsoluteTimeGetCurrent()

		guard currentTime > lastSend + sendDelta else { return }
		let message = WSMessage(messageType: .positionPulse, payload: PositionPulseUpdate(position: position, destination: destination))

		do {
			let bin = try message.encode()
			webSocketConnection.send(data: bin)
			lastSend = currentTime
		} catch {
			NSLog("Error encoding position pulse: \(error)")
		}
	}

	func sendChatMessage(_ message: String) {
		guard connected else { return }
		guard let packet = WSPacket(type: .chatMessage, content: ["message" : message]).json else { return }
		webSocketConnection.send(text: packet)
	}

	func playerAttacked(facing: PlayerDirection, hit players: [Player]) {
		guard connected else { return }
		let victimIDs = players.map { $0.id }
		guard let packet = WSPacket(type: .playerAttack, content: ["direction": facing.rawValue, "hitPlayers": victimIDs]).json else { return }
		webSocketConnection.send(text: packet)
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
		if let magic = data.getMagic() {
			switch magic {
			case .positionPulse:
				handlePositionPulse(from: data)
			case .chatMessage:
				break
			case .playerAttack:
				break
			case .positionUpdate:
				break
			}
		} else {
			print("got data: \(data)")
		}
	}

	private func handlePositionPulse(from data: Data) {
		let playerPositions: [String: PositionPulseUpdate]
		do {
			playerPositions = try data.extractPayload(payloadType: [String: PositionPulseUpdate].self)
		} catch {
			NSLog("Error decoding player positions from pulse: \(error)")
			return
		}
		print(playerPositions)
		liveInteractionDelegate?.otherPlayersUpdated(on: self, updatedPositions: playerPositions)
	}

	private func distributechatData(data: Any) {
		guard let dict = data as? [String: String] else { return }
		guard let message = dict["message"], let playerID = dict["player"] else { return }
		liveInteractionDelegate?.chatReceived(on: self, message: message, playerID: playerID)
	}

	private func distributePositionPulseData(data: Any) {
		guard let dict = data as? [String: [String: [CGFloat]]] else { return }

		var otherPlayers = [String: PositionPulseUpdate]()
		for (playerID, positionDict) in dict {
			guard let positions = positionDict["position"],
				positions.count == 2,
				let destinationList = positionDict["destination"],
				destinationList.count == 2 else { continue }
			let position = CGPoint(x: positions[0], y: positions[1])
			let destination = CGPoint(x: destinationList[0], y: destinationList[1])
			otherPlayers[playerID] = PositionPulseUpdate(position: position, destination: destination)
		}

		liveInteractionDelegate?.otherPlayersUpdated(on: self, updatedPositions: otherPlayers)
	}

	private func distributeAttackBroadcast(data: Any) {
		guard let dict = data as? [String: Any] else { return }
		guard let attackingPlayer = dict["playerID"] as? String, let hitPlayers = dict["hitPlayers"] as? [String] else { return }
		liveInteractionDelegate?.attackBroadcastReceived(on: self, from: attackingPlayer, hitPlayers: hitPlayers)
	}

}
