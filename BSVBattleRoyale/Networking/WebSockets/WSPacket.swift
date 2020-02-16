//
//  File.swift
//  BSVBattleRoyale
//
//  Created by Michael Redig on 2/4/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import Foundation

enum WSPacketType: String {
	case positionUpdate
	case positionPulse
	case chatMessage
	case playerAttack
}

struct WSPacket {
	let type: WSPacketType
	let content: [String: Any]

	var json: String? {
		let jsonDict: [String: Any] = ["messageType": type.rawValue, "data": content]

		let jsonData: Data
		do {
			jsonData = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
		} catch {
			NSLog("Error encoding new position: \(error)")
			return nil
		}
		return String(data: jsonData, encoding: .utf8)
	}
}
