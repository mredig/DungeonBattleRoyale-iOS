//
//  ViewController.swift
//  BSVBattleRoyale
//
//  Created by joshua kaunert on 2/4/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import UIKit
import SpriteKit
import NetworkHandler

class ViewController: UIViewController {

	// MARK: - Properties
	var mapController: MapController?
	var liveConntroller: LiveConnectionController?
	var apiController: APIController?
	var currentScene: RoomScene?

	var playerInfo = PlayerState(playerID: "", spawnLocation: .zero) {
		didSet {
			DispatchQueue.main.async {
				self.updateSpriteKit()
			}
		}
	}

	override var prefersStatusBarHidden: Bool { true }

	private var disconnectTimer: Timer?

	// MARK: - Outlets
	@IBOutlet weak var gameView: SKView!
	@IBOutlet weak var mapGroup: UIView!
	@IBOutlet weak var mapImage: UIImageView!
	@IBOutlet weak var currentRoomMapImage: UIImageView!
	@IBOutlet weak var respawnButton: UIButton!

	@IBOutlet weak var chatTextField: UITextField!
	@IBOutlet weak var chatSendButton: UIButton!
	@IBOutlet weak var textFieldInputConstraint: NSLayoutConstraint!
	@IBOutlet weak var latencyLabel: UILabel!
	
	// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		mapGroup.isHidden = true
		updateWorldMap()
		setupKeyboardInputStuff()
	}

	private func setupKeyboardInputStuff() {
		chatTextField.delegate = self
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
	}

	func updateSpriteKit() {
		let scene = RoomScene(size: gameView.frame.size)
		currentScene = scene
		scene.scaleMode = .aspectFit
		gameView.presentScene(scene, transition: .fade(with: .black, duration: 0.5))
		gameView.isMultipleTouchEnabled = true
		// ⬇⬇⬇ Comment out for screengrabs
//		gameView.showsFPS = true
//		gameView.showsPhysics = true
//		gameView.showsDrawCount = true
//		gameView.showsNodeCount = true
//		gameView.showsQuadCount = true
        // ⬆⬆⬆ Comment out for screengrabs

		if liveConntroller == nil {
			liveConntroller = LiveConnectionController(playerID: playerInfo.playerID)
		}
		liveConntroller?.delegate = self

		scene.apiController = apiController
		scene.loadRoom(room: mapController?.currentRoom, playerPosition: playerInfo.spawnLocation, playerID: playerInfo.playerID)
		scene.liveController = liveConntroller
		scene.roomDelegate = self
		disconnectTimer?.invalidate()

		currentRoomMapImage.image = mapController?.generateCurrentRoomOverlay()
	}

	func updateWorldMap() {
		apiController?.getWorldmap { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let rooms):
				let mc = MapController(roomCollection: rooms)
				self.mapController = mc
				self.initializePlayer(respawn: false)
				DispatchQueue.main.async {
					mc.scale = self.view.frame.width / max(mc.unscaledSize.width, mc.unscaledSize.height)
					self.mapImage.image = self.mapController?.generateOverworldMap()
				}
			case .failure(let error):
				NSLog("Failed getting world map: \(error)")
			}
		}
	}

	func initializePlayer(respawn: Bool) {
		apiController?.initializePlayer(respawn: respawn) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let playerInit):
				self.mapController?.currentRoom = self.mapController?.room(for: playerInit.roomID)
				self.playerInfo = PlayerState(playerID: playerInit.playerID, spawnLocation: playerInit.spawnLocation)
			case .failure(let error):
				NSLog("Failed initing player: \(error)")
			}
		}
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		gameView.scene?.size = size
	}

	// MARK: - Actions
	@objc func keyboardFrameWillChange(notification: NSNotification) {
		guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
		let duration: NSNumber = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber ?? 0.2

		animateTextField(to: keyboardRect.height, duration: TimeInterval(truncating: duration))
	}

	func animateTextField(to height: CGFloat, duration: TimeInterval) {
		UIView.animate(withDuration: duration) {
			self.textFieldInputConstraint.constant = height
			self.view.layoutSubviews()
		}
	}

	@IBAction func respawnButtonPressed(_ sender: UIButton) {
		initializePlayer(respawn: true)
		respawnButton.isHidden = true
	}

	@IBAction func mapButtonPressed(_ sender: UIButton) {
		mapGroup.isHidden.toggle()
	}

	@IBAction func disconnectButtonPressed(_ sender: UIButton) {
		disconnectAndDismiss()
	}

	private func disconnectAndDismiss() {
		DispatchQueue.main.async {
			self.apiController?.token = nil
			self.liveConntroller?.disconnect()
			self.liveConntroller = nil
			self.disconnectTimer?.invalidate()
			self.currentScene?.clearPlayerCache()
			self.dismiss(animated: true)
		}
	}

	@IBAction func chatSendPressed(_ sender: UIButton) {
		sendChatMessage()
	}

	private func sendChatMessage() {
		animateTextField(to: 0, duration: 0.2)
		chatTextField.resignFirstResponder()
		guard let text = chatTextField.text, !text.isEmpty else { return }
		liveConntroller?.sendChatMessage(text)
		chatTextField.text = ""
	}
}

extension ViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		sendChatMessage()
		return true
	}
}

extension ViewController: LiveConnectionControllerDelegate {

	func socketConnected(_ connection: LiveConnectionController) {
	}

	func socketDisconnected() {
		disconnectTimer?.invalidate()
		// this is error prone at best. it's intended to allow the short disconnect from websockets as a player
		// navigates from one room to another, then check to see if the user is still disconnected in a few seconds
		// and only THEN dismiss and end the session... but if the ws reconnects and enters another room, no dismissal
		// and no session end. however, it fires multiple times on a disconnect and invalidating the previous timer
		// doesn't seem to work, so multiple timers end up running simultaneously
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.disconnectTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { [weak self] timer in
//				print("if still disconnected, dismissing view: \(timer)")
				guard let self = self else { return }
				if self.liveConntroller?.connected != true {
//					print("disconnected")
					self.disconnectAndDismiss()
				} else {
//					print("reconnected")
				}
				timer.invalidate()
				self.disconnectTimer?.invalidate()
			})
		}
	}

	func socketLatencyUpdated(_ connection: LiveConnectionController, latency ms: Double) {
		DispatchQueue.main.async {
			self.latencyLabel.text = "\(Int(ms)) ms"
		}
	}
}

extension ViewController: RoomSceneDelegate {
	func player(_ currentPlayer: Player, enteredDoor: DoorSprite) {
		let oldRoom = mapController?.currentRoom?.id
		apiController?.movePlayer(to: enteredDoor.id) { [weak self] result in
			print("Entering \(enteredDoor.id) from \(oldRoom!)")
			guard let self = self else { return }
			switch result {
			case .success(let playerMove):
				self.mapController?.currentRoom = self.mapController?.room(for: playerMove.currentRoom)
				self.playerInfo.spawnLocation = playerMove.spawnLocation
			case .failure(let error):
                if let terror = error as NetworkError? {
					switch terror {
					case .dataCodingError(specifically: _, sourceData: let data):
						let str = String(data: data!, encoding: .utf8)
                        print("Got \(String(describing: str))")
					default:
						break
					}
				}
                NSLog("Failed moving player: \(error)")
			}
		}
	}

	func playerDied(_ currentPlayer: Player) {
		respawnButton.isHidden = false
	}
}
