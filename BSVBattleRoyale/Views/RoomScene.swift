//
//  RoomScene.swift
//  BSVBattleRoyale
//
//  Created by Michael Redig on 2/4/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import SpriteKit


protocol RoomSceneDelegate: AnyObject {
	func player(_ currentPlayer: Player, enteredDoor: DoorSprite)
	func playerDied(_ currentPlayer: Player)
}

class RoomScene: SKScene {

	var allPlayers = [String: Player]()

	let background = RoomSprite()
	var currentPlayer: Player?
	var liveController: LiveConnectionController? {
		didSet {
			liveController?.liveInteractionDelegate = self
		}
	}
	var apiController: APIController?
	weak var roomDelegate: RoomSceneDelegate?

	private static var _playerInfoFetchTasks = [String: URLSessionDataTask]()
	private static var _playerInfo = [String: PlayerInfo]()


	private lazy var fadeSprite: SKSpriteNode = {
		let sp = SKSpriteNode(color: .black, size: self.size)
		self.camera?.addChild(sp)
		sp.alpha = 0
		return sp
	}()

	#if DEBUG
	lazy var sampleSprites: [HasColor] = {
		(0...10000).map { _ in
			let sample = SKSpriteNode(color: .green, size: CGSize(scalar: 3))
			sample.position = CGPoint(x: .random(in: 0...800), y: .random(in: 0...800))
			sample.alpha = 0.5
			sample.zPosition = 0.5
			addChild(sample)
			return sample
		}
	}()
	#endif

	// MARK: - Lifecycle
	override func didMove(to view: SKView) {
		super.didMove(to: view)
		setupScene()
	}

	func setupScene() {
		addChild(background)

		physicsWorld.gravity = CGVector.zero
		physicsWorld.contactDelegate = self
	}

	func loadRoom(room: Room?, playerPosition: CGPoint, playerID: String) {
		background.room = room

		let newPlayer = Player(avatar: .greenMonster, id: playerID, username: "", position: playerPosition)
		addChild(newPlayer)
		currentPlayer = newPlayer
		newPlayer.zPosition = 1
		currentPlayer?.enableTouchBox(true)
		currentPlayer?.interactionDelegate = self

		allPlayers[newPlayer.id] = newPlayer
		loadInfoForPlayer(newPlayer)

		let playerCamera = SKCameraNode()
		newPlayer.addChild(playerCamera)
		camera = playerCamera
	}

	// MARK: - User input
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		touches.forEach { setPlayerTrajectory(towards: $0.location(in: self)) }
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)
		touches.forEach { setPlayerTrajectory(towards: $0.location(in: self)) }
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		setPlayerTrajectory(to: .zero)
	}

	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesCancelled(touches, with: event)
		setPlayerTrajectory(to: .zero)
	}

	private func setPlayerTrajectory(towards location: CGPoint) {
		guard let player = currentPlayer, player.isAlive else { return }
		let trajectory = player.position.vector(facing: location)
		currentPlayer?.trajectory = trajectory
		liveController?.updatePlayerPosition(player.position, trajectory: trajectory)
	}

	private func setPlayerTrajectory(to trajectory: CGVector) {
		currentPlayer?.trajectory = trajectory
		guard let player = currentPlayer else { return }
		liveController?.updatePlayerPosition(player.position, trajectory: trajectory)
	}

	/// Returns 0 if the attack didn't land
	private func meleeAttackStrength(on victim: Player, from strikePosition: CGPoint, facing: CGVector) -> CGFloat {
		if victim.position.isInFront(of: strikePosition, facing: facing, withLatitude: 0.75) {
			let distance = victim.position.distance(to: strikePosition)
			let maxDistance: CGFloat = 65
			let playerHitboxRadius = victim.physicsBodyRadius
			if distance < maxDistance {
				let strength = 1 - CGFloat((0...maxDistance - playerHitboxRadius).linearPoint(of: distance - playerHitboxRadius))
				return strength
			} else {
				return 0
			}
		} else {
			return 0
		}
	}

	private func allMeleeAttackVictims() -> [AttackContact] {
		guard let player = currentPlayer else { return [] }

		var contacts = [AttackContact]()
		let strikePos = player.strikePosition
		for (id, otherPlayer) in allPlayers {
			guard otherPlayer != player else { continue }
			let strength = meleeAttackStrength(on: otherPlayer, from: strikePos, facing: player.direction.facingVector)
			guard strength > 0 else { continue }
			let hitVector = strikePos.vector(facing: otherPlayer.position)
			contacts.append(AttackContact(victim: id, vector: hitVector, strength: strength))
		}
		return contacts
	}

	// MARK: - game loop
	override func update(_ currentTime: TimeInterval) {
		super.update(currentTime)

		// send player position
		guard let player = currentPlayer else { return }
		liveController?.sendPositionPulse(player.position, trajectory: player.trajectory)

		// FIXME: For debugging
//		#if DEBUG
//		let strikePosition = player.strikePosition
//		for otherPlayer in otherPlayers.values {
//			otherPlayer.color = meleeAttackStrength(on: otherPlayer, from: strikePosition, facing: player.direction.facingVector) > 0 ? .green : .red
//			otherPlayer.colorBlendFactor = 1
//		}
//		#endif
	}

	// MARK: - other player interaction
	func updateFromPulse(updates: Set<PulseUpdate>) {
		var extraPlayers = allPlayers
		for update in updates {
			// other or current player, already in scene
			if let player = allPlayers[update.playerID] {
				updateExistingPlayerHealth(player, healthUpdate: update.health)
				if player != currentPlayer {
					updateExistingPlayerPosition(player, positionUpdate: update.positionUpdate)
				}
			} else {
				// new player - add to scene and initialize position
				let positionUpdate = update.positionUpdate
				let addtlPlayer = Player(avatar: .yellowMonster, id: update.playerID, username: "", position: positionUpdate.position)
				addChild(addtlPlayer)
				allPlayers[update.playerID] = addtlPlayer
				addtlPlayer.setPosition(to: positionUpdate.position)
				updateExistingPlayerHealth(addtlPlayer, healthUpdate: update.health)
				loadInfoForPlayer(addtlPlayer)
			}
			extraPlayers[update.playerID] = nil
		}

		for (id, deletePlayer) in extraPlayers {
			allPlayers[id] = nil
			RoomScene._playerInfo[id] = nil
			deletePlayer.removeFromParent()
		}
	}

	private func updateExistingPlayerPosition(_ player: Player, positionUpdate: PositionUpdate) {
		// don't change current player's position
		guard player != currentPlayer else { return }
		// update any other consistent player's position
		if player.position.distance(to: positionUpdate.position, isWithin: 50) {
			player.trajectory = positionUpdate.trajectory
			player.destination = positionUpdate.position
		} else {
			player.setPosition(to: positionUpdate.position)
		}
	}

	private func updateExistingPlayerHealth(_ player: Player, healthUpdate: PlayerHealthUpdate) {
		player.maxHP = healthUpdate.maxHP
		player.currentHP = healthUpdate.currentHP

		if player.currentHP == 0 && player == currentPlayer {
			roomDelegate?.playerDied(player)
		}
	}

	func chatReceived(from playerID: String, message: String) {
		if let player = allPlayers[playerID] {
			player.say(message: message)
		}
	}

	func attackReceived(from playerID: String, attackContacts: [AttackContact]) {
		if let player = allPlayers[playerID] {
			player.attack()
		}

		attackContacts.forEach {
			if let victim = allPlayers[$0.victim] {
				victim.hitAnimation(from: $0.vector)
			}
		}
	}

	func loadInfoForPlayer(_ player: Player) {
		if let playerInfo = RoomScene._playerInfo[player.id] {
			DispatchQueue.main.async {
				player.avatar = Avatar(rawValue: playerInfo.avatar) ?? .yellowMonster
				player.username = playerInfo.username
			}
		} else {
			guard RoomScene._playerInfoFetchTasks[player.id] == nil else { return }
			RoomScene._playerInfoFetchTasks[player.id] = apiController?.fetchPlayerInfo(for: player.id, completion: { [weak self] result in
				switch result {
				case .success(let info):
					RoomScene._playerInfo[player.id] = info
					self?.loadInfoForPlayer(player)
				case .failure(let error):
					print("Error fetching player info for \(player.id): \(error)")
				}
				RoomScene._playerInfoFetchTasks[player.id] = nil
			})
		}
	}

	func clearPlayerCache() {
		RoomScene._playerInfo.removeAll()
	}
}

// MARK: - Physics
extension RoomScene: SKPhysicsContactDelegate {

	func didBegin(_ contact: SKPhysicsContact) {
		let bodies = Set([contact.bodyB, contact.bodyA])
		var physicNodes = Set(bodies.compactMap { $0.node })

		if let currentPlayer = currentPlayer {
			if physicNodes.contains(currentPlayer) && physicNodes.contains(background) {
//				currentPlayer.stopMove()
			}

			// one of the nodes is player
			if physicNodes.remove(currentPlayer) != nil {
				if let door = physicNodes.removeFirst() as? DoorSprite {
					currentPlayer.physicsBody = nil
					let action = SKAction.fadeIn(withDuration: 0.1)
					fadeSprite.run(action)
					roomDelegate?.player(currentPlayer, enteredDoor: door)
				}
			}
		}
	}
}

// MARK: - Network interactions - xmit
extension RoomScene: PlayerInteractionDelegate {
	func player(_ player: Player, attackedFacing facing: PlayerDirection) {
		let hits = allMeleeAttackVictims()
		liveController?.playerAttacked(facing: facing, hits: hits)
	}
}

// MARK: - Network interactions - rec
extension RoomScene: LiveInteractionDelegate {
	func pulseUpdates(on controller: LiveConnectionController, updates: Set<PulseUpdate>) {
		DispatchQueue.main.async {
			self.updateFromPulse(updates: updates)
		}
	}

	func otherPlayerMoved(on controller: LiveConnectionController, update: PositionUpdate) {
		guard let updateID = update.playerID, updateID != currentPlayer?.id, let player = allPlayers[updateID] else { return }
		DispatchQueue.main.async {
			self.updateExistingPlayerPosition(player, positionUpdate: update)
		}
	}

	func chatReceived(on controller: LiveConnectionController, message: String, playerID: String) {
		DispatchQueue.main.async {
			self.chatReceived(from: playerID, message: message)
		}
	}

	func attackBroadcastReceived(on controller: LiveConnectionController, from playerID: String, attackContacts: [AttackContact]) {
		DispatchQueue.main.async {
			self.attackReceived(from: playerID, attackContacts: attackContacts)
		}
	}
}
