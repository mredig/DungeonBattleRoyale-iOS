//
//  ViewController.swift
//  BSVBattleRoyale
//
//  Created by joshua kaunert on 2/4/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

	@IBOutlet weak var gameView: SKView!

	var mapController: MapController?

	var liveConntroller: LiveConnectionController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

		let scene = RoomScene(size: gameView.frame.size)
		scene.scaleMode = .aspectFit
		gameView.presentScene(scene)
		gameView.showsFPS = true
		gameView.showsPhysics = true


		// FIXME: For testing
		guard let url = backendBaseURL?
			.appendingPathComponent("api")
			.appendingPathComponent("worldmap") else { return }


		do {
			let data = try Data(contentsOf: url)
			mapController = try MapController(jsonData: data)
		} catch {
			NSLog("Failed opening: \(error)")
			return
		}

		liveConntroller = LiveConnectionController(playerID: "71777254-4c12-4d36-adc2-858dda19ac98")

		scene.loadRoom(room: mapController?.currentRoom, playerPosition: CGPoint(x: 370, y: 20))
		scene.liveController = liveConntroller
	}
}
