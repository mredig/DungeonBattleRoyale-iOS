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
	func socketConnected(_ connection: LiveConnectionController)
	func socketLatencyUpdated(_ connection: LiveConnectionController, latency ms: Double)
}

protocol LiveInteractionDelegate: AnyObject {
	func pulseUpdates(on controller: LiveConnectionController, updates: Set<PulseUpdate>)
	func otherPlayerMoved(on controller: LiveConnectionController, update: PositionUpdate)
	func chatReceived(on controller: LiveConnectionController, message: String, playerID: String)
	func attackBroadcastReceived(on controller: LiveConnectionController, from playerID: String, attackContacts: [AttackContact])
}

class LiveConnectionController {
	// MARK: - Properties
	var webSocketConnection: WebSocketConnection

	private(set) var connected = false
	weak var delegate: LiveConnectionControllerDelegate?
	weak var liveInteractionDelegate: LiveInteractionDelegate?
	private let playerID: String
	private var totalDataSent = 0
	private var totalDataReceived = 0

	private var latencyPingTimer: Timer?
	private let pingFailThreshold = 10
	private let pingQueue = DispatchQueue(label: "PingQueue")
	private var _pings = Set<LatencyPing>()
	private var pings: Set<LatencyPing> {
		get { pingQueue.sync { _pings } }
		set { pingQueue.sync { _pings = newValue } }
	}

	private let genesisTime: CFAbsoluteTime

	// MARK: - Lifecycle
	init?(playerID: String) {
		guard let url = backendWSURL?
			.appendingPathComponent("ws")
			.appendingPathComponent("rooms")
			.appendingPathComponent(playerID) else { return nil }

		self.playerID = playerID
		genesisTime = CFAbsoluteTimeGetCurrent()

		webSocketConnection = WebSocketTaskConnection(url: url)
		webSocketConnection.delegate = self
		webSocketConnection.connect()

		DispatchQueue.global(qos: .background).async {
			let latencyTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
				self?.checkLatency()
			})
			self.latencyPingTimer = latencyTimer
			RunLoop.current.add(latencyTimer, forMode: .default)
			RunLoop.current.run()
		}
	}

	deinit {
		print("bye live conn")
		latencyPingTimer?.invalidate()
		latencyPingTimer = nil
	}

	func disconnect() {
		webSocketConnection.disconnect()
	}

	// MARK: - Outgoing messages
	private var lastCachedPosition: PositionUpdate?
	private let positionUpdateSendDelta: TimeInterval = 1/15
	private var lastPositionUpdateSend = TimeInterval(0)
	private var someTimer: Timer?
	func updatePlayerPosition(_ position: CGPoint, trajectory: CGVector) {
		guard connected else { return }
		lastCachedPosition = PositionUpdate(position: position, trajectory: trajectory)
		let currentTime = CFAbsoluteTimeGetCurrent()
		let nextValidSendTime = lastPositionUpdateSend + positionUpdateSendDelta

		guard currentTime > nextValidSendTime else {
			if someTimer == nil {
				someTimer = Timer.scheduledTimer(withTimeInterval: nextValidSendTime - currentTime, repeats: false, block: { [weak self] _ in
					self?.someTimer = nil
					self?.sendPlayerPositionUpdate()
				})
			}
			return
		}
		sendPlayerPositionUpdate()
	}

	private func sendPlayerPositionUpdate() {
		guard let lastPos = lastCachedPosition else { return }
		let message = WSMessage(messageType: .positionUpdate, payload: lastPos)
		lastCachedPosition = nil
		encodeAndSend(binaryMessage: message)
		lastPositionUpdateSend = CFAbsoluteTimeGetCurrent()
	}

	private var lastPositionPulseSend = TimeInterval(0)
	let positionPulseSendDelta: TimeInterval = 1/3
	func sendPositionPulse(_ position: CGPoint, trajectory: CGVector) {
		guard connected else { return }
		let currentTime = CFAbsoluteTimeGetCurrent()

		guard currentTime > lastPositionPulseSend + positionPulseSendDelta else { return }
		let message = WSMessage(messageType: .positionPulse, payload: PositionUpdate(position: position, trajectory: trajectory))

		encodeAndSend(binaryMessage: message)
		lastPositionPulseSend = currentTime
	}

	func sendChatMessage(_ message: String) {
		guard connected else { return }
		let message = WSMessage(messageType: .chatMessage, payload: ChatMessage(message: message, playerID: playerID))
		encodeAndSend(binaryMessage: message)
	}

	func playerAttacked(facing: PlayerDirection, hits: [AttackContact]) {
		guard connected else { return }
		let message = WSMessage(messageType: .playerAttack, payload: PlayerAttack(attacker: playerID, attackContacts: hits))
		encodeAndSend(binaryMessage: message)
	}

	private func checkLatency() {
		guard connected else { return }
		let ping = LatencyPing(timestamp: Date())
		let message = WSMessage(messageType: .latencyPing, payload: ping)
		encodeAndSend(binaryMessage: message)
		pings.insert(ping)

		removeIrrelevantlyOldPings()
		if pings.count > pingFailThreshold {
			NSLog("Too many dropped pings.")
			disconnect()
		}
	}

	private func encodeAndSend<Payload: Codable>(binaryMessage message: WSMessage<Payload>) {
		do {
			let bin = try message.encode()
			webSocketConnection.send(data: bin)
			totalDataSent += bin.count
		} catch {
			NSLog("Error encoding message with payload type \(type(of: message.payload)): \(error)")
		}
	}

	/// calculates the average connection data rate in KBps
	private func tabulateDataRate() -> (sendRate: Double, receiveRate: Double) {
		let currentTime = CFAbsoluteTimeGetCurrent()
		let elapsed = currentTime - genesisTime
		let sendbps = Double(totalDataSent) / elapsed
		let sendkbps = sendbps / 1024
		let recbps = Double(totalDataReceived) / elapsed
		let reckbps = recbps / 1024
		return (sendkbps, reckbps)
	}
}

// MARK: - Delegate
extension LiveConnectionController: WebSocketConnectionDelegate {
	func onConnected(connection: WebSocketConnection) {
		print("connected!")
		connected = true
		delegate?.socketConnected(self)
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
			case .latencyPing:
				handleLatencyPingback(from: data)
			}
		} else {
			print("got data: \(data)")
		}
		totalDataReceived += data.count
	}

	// MARK: - Incoming message handling
	private func extractPayload<Payload: Codable>(of type: Payload.Type, from data: Data) -> Payload? {
		do {
			return try data.extractPayload(payloadType: type)
		} catch {
			let (_, extractedData) = data.separateMagicAndData()
			NSLog("Error decoding payload of type \(type): \(error)")
			if let plist = try? PropertyListSerialization.propertyList(from: extractedData, options: [], format: nil) {
				print("Extracted data: \(plist)")
			}
			return nil
		}
	}

	private func handleLatencyPingback(from data: Data) {
		guard let pingTime = extractPayload(of: LatencyPing.self, from: data) else { return }
		let difference = Date().timeIntervalSince(pingTime.timestamp) * 1000
		let dataRate = tabulateDataRate()
		pings.remove(pingTime)
		print("latency: \(difference) ms, datarate: sending \(dataRate.sendRate) kBps | rec \(dataRate.receiveRate) kBps | awaiting pings: \(pings.count)")
		delegate?.socketLatencyUpdated(self, latency: difference)
	}

	private func removeIrrelevantlyOldPings() {
		guard let pingTimer = latencyPingTimer else { return }
		let oldestValue = Date(timeIntervalSinceNow: -pingTimer.timeInterval * TimeInterval(pingFailThreshold) * 10)
		pings = pings.filter { $0.timestamp > oldestValue }
	}

	private func handlePositionPulse(from data: Data) {
		guard let updates = extractPayload(of: Set<PulseUpdate>.self, from: data) else { return }
		liveInteractionDelegate?.pulseUpdates(on: self, updates: updates)
	}

	private func handlePlayerPositionUpdate(from data: Data) {
		guard let playerPosition = extractPayload(of: PositionUpdate.self, from: data) else { return }
		liveInteractionDelegate?.otherPlayerMoved(on: self, update: playerPosition)
	}

	private func handleChatMessage(from data: Data) {
		guard let chatMessage = extractPayload(of: ChatMessage.self, from: data) else { return }
		liveInteractionDelegate?.chatReceived(on: self, message: chatMessage.message, playerID: chatMessage.playerID)
	}

	private func handleAttackMessage(from data: Data) {
		guard let attackMessage = extractPayload(of: PlayerAttack.self, from: data) else { return }
		liveInteractionDelegate?.attackBroadcastReceived(on: self, from: attackMessage.attacker, attackContacts: attackMessage.attackContacts)
	}
}
