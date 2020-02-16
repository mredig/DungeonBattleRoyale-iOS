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
	func socketDisconnected()
}

protocol LiveInteractionDelegate: AnyObject {
	func positionPulse(on controller: LiveConnectionController, updatedPositions: [String: PositionPulseUpdate])
	func otherPlayerMoved(on controller: LiveConnectionController, update: PositionPulseUpdate)
	func chatReceived(on controller: LiveConnectionController, message: String, playerID: String)
	func attackBroadcastReceived(on controller: LiveConnectionController, from playerID: String, hitPlayers: [String])
}

class LiveConnectionController {
	// MARK: - Properties
	var webSocketConnection: WebSocketConnection

	private(set) var connected = false
	weak var delegate: LiveConnectionControllerDelegate?
	weak var liveInteractionDelegate: LiveInteractionDelegate?
	private let playerID: String

	// MARK: - Lifecycle
	init?(playerID: String) {
		guard let url = backendWSURL?
			.appendingPathComponent("ws")
			.appendingPathComponent("rooms")
			.appendingPathComponent(playerID) else { return nil }

		self.playerID = playerID

		webSocketConnection = WebSocketTaskConnection(url: url)
		webSocketConnection.delegate = self
		webSocketConnection.connect()
	}

	func disconnect() {
		webSocketConnection.disconnect()
	}

	// MARK: - Outgoing messages
	func updatePlayerPosition(_ position: CGPoint, destination: CGPoint) {
		guard connected else { return }
		let message = WSMessage(messageType: .positionUpdate, payload: PositionPulseUpdate(position: position, destination: destination))

		encodeAndSend(binaryMessage: message)
	}

	private var lastSend = TimeInterval(0)
	let sendDelta: TimeInterval = 1/3
	func sendPositionPulse(_ position: CGPoint, destination: CGPoint) {
		guard connected else { return }
		let currentTime = CFAbsoluteTimeGetCurrent()

		guard currentTime > lastSend + sendDelta else { return }
		let message = WSMessage(messageType: .positionPulse, payload: PositionPulseUpdate(position: position, destination: destination))

		encodeAndSend(binaryMessage: message)
	}

	func sendChatMessage(_ message: String) {
		guard connected else { return }
		let message = WSMessage(messageType: .chatMessage, payload: ChatMessage(message: message, playerID: playerID))
		encodeAndSend(binaryMessage: message)
	}

	func playerAttacked(facing: PlayerDirection, hit players: [Player]) {
		guard connected else { return }
		let victimIDs = players.map { $0.id }
		let message = WSMessage(messageType: .playerAttack, payload: PlayerAttack(attacker: playerID, hitPlayers: victimIDs))
		encodeAndSend(binaryMessage: message)
	}

	private func encodeAndSend<Payload: Codable>(binaryMessage message: WSMessage<Payload>) {
		do {
			let bin = try message.encode()
			webSocketConnection.send(data: bin)
		} catch {
			NSLog("Error encoding message with payload type \(type(of: message.payload)): \(error)")
		}
	}
}

// MARK: - Delegate
extension LiveConnectionController: WebSocketConnectionDelegate {
	func onConnected(connection: WebSocketConnection) {
		print("connected!")
		connected = true
	}

	func onDisconnected(connection: WebSocketConnection, error: Error?) {
		print("disconnected: \(String(describing: error))")
		connected = false
		delegate?.socketDisconnected()
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
				handleChatMessage(from: data)
			case .playerAttack:
				handleAttackMessage(from: data)
			case .positionUpdate:
				handlePlayerPositionUpdate(from: data)
			}
		} else {
			print("got data: \(data)")
		}
	}

	// MARK: - Incoming message handling
	private func extractPayload<Payload: Codable>(of type: Payload.Type, from data: Data) -> Payload? {
		do {
			return try data.extractPayload(payloadType: type)
		} catch {
			NSLog("Error decoding payload of type \(type): \(error)")
			return nil
		}
	}

	private func handlePositionPulse(from data: Data) {
		guard let playerPositions = extractPayload(of: [String: PositionPulseUpdate].self, from: data) else { return }
		liveInteractionDelegate?.positionPulse(on: self, updatedPositions: playerPositions)
	}

	private func handlePlayerPositionUpdate(from data: Data) {
		guard let playerPosition = extractPayload(of: PositionPulseUpdate.self, from: data) else { return }
		liveInteractionDelegate?.otherPlayerMoved(on: self, update: playerPosition)
	}

	private func handleChatMessage(from data: Data) {
		guard let chatMessage = extractPayload(of: ChatMessage.self, from: data) else { return }
		liveInteractionDelegate?.chatReceived(on: self, message: chatMessage.message, playerID: chatMessage.playerID)
	}

	private func handleAttackMessage(from data: Data) {
		guard let attackMessage = extractPayload(of: PlayerAttack.self, from: data) else { return }
		liveInteractionDelegate?.attackBroadcastReceived(on: self, from: attackMessage.attacker, hitPlayers: attackMessage.hitPlayers)
	}
}
