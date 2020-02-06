//
//  Constants.swift
//  BSVBattleRoyale
//
//  Created by Michael Redig on 2/5/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import Foundation


let doorBitmask: UInt32 = 1 << 0
let wallBitmask: UInt32 = 1 << 1
let playerBitmask: UInt32 = 1 << 2

//let backendDomain = "bsvbattle.redig.me:8080" //dev
let backendDomain = "bsvbattle.redig.me:8000" //testflight
//let backendDomain = "localhost:8000" //local
let backendBaseURL = URL(string: "http://\(backendDomain)/")
let backendWSURL = URL(string: "ws://\(backendDomain)")
