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

//let backendDomain = "localhost:8000" //local
//let backendDomain = "bsvbattle.redig.me:8040" //dev
let backendDomain = "bsvbattle.redig.me" //testflight
fileprivate let restProtocol = "https"
fileprivate let wsProtocol = "wss"
let backendBaseURL = URL(string: "\(restProtocol)://\(backendDomain)/")
let backendWSURL = URL(string: "\(wsProtocol)://\(backendDomain)")
