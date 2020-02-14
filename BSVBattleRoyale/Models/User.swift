//
//  User.swift
//  BSVBattleRoyale
//
//  Created by John Pitts on 2/4/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import Foundation

struct User: Codable {
	let username: String
    let password: String
    let passwordVerify: String?
}
