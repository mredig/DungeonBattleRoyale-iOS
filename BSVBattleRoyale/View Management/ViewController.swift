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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

		let scene = RoomScene(size: gameView.frame.size)
		scene.scaleMode = .aspectFit
		gameView.presentScene(scene)
		gameView.showsFPS = true
		gameView.showsPhysics = true
	}
}
