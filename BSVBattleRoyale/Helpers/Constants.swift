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

#if DEBUG
let backendDomain = "imac.nl.redig.me:8080" //local
fileprivate let restProtocol = "http"
fileprivate let wsProtocol = "ws"
#else
let backendDomain = "bsvbattle.herokuapp.com" //testflight
fileprivate let restProtocol = "https"
fileprivate let wsProtocol = "wss"
#endif

let backendBaseURL = URL(string: "\(restProtocol)://\(backendDomain)/")
let backendWSURL = URL(string: "\(wsProtocol)://\(backendDomain)")
