//
//  SpriteKit+Helpers.swift
//  BSVBattleRoyale
//
//  Created by Michael Redig on 2/4/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import SpriteKit

extension SKNode {
	var zRotationDegrees: CGFloat {
		get { zRotation * (180 / CGFloat.pi) }
		set { zRotation = newValue * (CGFloat.pi / 180) }
	}
}
