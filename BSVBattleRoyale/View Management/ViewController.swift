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

	@IBOutlet weak var gameView: SKView!
	@IBOutlet weak var mapGroup: UIView!
	@IBOutlet weak var mapImage: UIImageView!
	@IBOutlet weak var currentRoomMapImage: UIImageView!

	var mapController: MapController?
	var liveConntroller: LiveConnectionController?
	let apiController = APIController()

	var playerInfo = PlayerInfo(playerID: "", spawnLocation: .zero) {
		didSet {
			DispatchQueue.main.async {
				self.updateSpriteKit()
			}
		}
	}

	override var prefersStatusBarHidden: Bool { true }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		mapGroup.isHidden = true
		updateWorldMap()
	}

	func updateSpriteKit() {
		let scene = RoomScene(size: gameView.frame.size)
		scene.scaleMode = .aspectFit
		gameView.presentScene(scene, transition: .fade(with: .black, duration: 0.5))
		gameView.showsFPS = true
		gameView.showsPhysics = true


		scene.loadRoom(room: mapController?.currentRoom, playerPosition: playerInfo.spawnLocation)
		liveConntroller = LiveConnectionController(playerID: playerInfo.playerID)
		scene.liveController = liveConntroller
		scene.roomDelegate = self

		currentRoomMapImage.image = mapController?.generateCurrentRoomOverlay()
	}

	func updateWorldMap() {
		apiController.getWorldmap { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let rooms):
				let mc = MapController(roomCollection: rooms)
				self.mapController = mc
				self.initializePlayer()
			case .failure(let error):
				NSLog("Failed getting world map: \(error)")
			}
		}
	}

	func initializePlayer() {
		DispatchQueue.main.async {
			if let mc = self.mapController {
				mc.scale = self.view.frame.width / max(mc.unscaledSize.width, mc.unscaledSize.height)
			}
			self.mapImage.image = self.mapController?.generateOverworldMap()
		}
		apiController.initializePlayer { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let playerInit):
				self.mapController?.currentRoom = self.mapController?.room(for: playerInit.currentRoom)
				self.playerInfo = PlayerInfo(playerID: playerInit.playerID, spawnLocation: playerInit.spawnLocation)
			case .failure(let error):
				NSLog("Failed initing player: \(error)")
			}
		}
	}

	@IBAction func mapButtonPressed(_ sender: UIButton) {
		mapGroup.isHidden.toggle()
	}
}

extension ViewController: RoomSceneDelegate {
	func player(_ currentPlayer: Player, enteredDoor: DoorSprite) {
		let oldRoom = mapController?.currentRoom?.id
		apiController.movePlayer(to: enteredDoor.id) { [weak self] result in
			print("Entering \(enteredDoor.id) from \(oldRoom!)")
			guard let self = self else { return }
			switch result {
			case .success(let playerMove):
				self.mapController?.currentRoom = self.mapController?.room(for: playerMove.currentRoom)
				self.playerInfo.spawnLocation = playerMove.spawnLocation
			case .failure(let error):
				if let terror = error as? NetworkError {
					switch terror {
					case .dataCodingError(specifically: _, sourceData: let data):
						let str = String(data: data!, encoding: .utf8)
						print("Got \(str)")
					default:
						break
					}
				}
				NSLog("Failed moving player: \(error)")
			}
		}
	}
}
