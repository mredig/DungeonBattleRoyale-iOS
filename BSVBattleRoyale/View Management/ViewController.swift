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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

		let scene = RoomScene(size: gameView.frame.size)
		scene.scaleMode = .aspectFit
		gameView.presentScene(scene)
		gameView.showsFPS = true
		gameView.showsPhysics = true


		// FIXME: For testing
		guard let url = Bundle.main.url(forResource: "rooms10", withExtension: "json") else { return }

		do {
			let data = try Data(contentsOf: url)
			mapController = try MapController(jsonData: data)
		} catch {
			NSLog("Failed opening: \(error)")
			return
		}

		scene.background.room = mapController?.currentRoom
	}
}
