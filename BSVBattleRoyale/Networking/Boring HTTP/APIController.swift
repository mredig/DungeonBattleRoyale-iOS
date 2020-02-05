//
//  APIController.swift
//  BSVBattleRoyale
//
//  Created by Michael Redig on 2/5/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import Foundation
import NetworkHandler

class APIController {
	var token: TokenTemp? = TokenTemp(key: "ded69bb47c94b5a0716377d444b3297e94fc105f")
	let networkHandler = NetworkHandler.default

	func initializePlayer(completion: @escaping ((Result<PlayerInit, NetworkError>) -> Void)) {
		guard let url = backendBaseURL?.appendingPathComponent("api").appendingPathComponent("init"),
			let token = token else { return }

		var request = url.request
		request.addValue(.other(value: "Token \(token.key)"), forHTTPHeaderField: .commonKey(key: .authorization))
		request.addValue(.contentType(type: .json), forHTTPHeaderField: .commonKey(key: .contentType))

		networkHandler.transferMahCodableDatas(with: request, completion: completion)
	}

	func movePlayer(to room: String, completion: @escaping ((Result<PlayerMove, NetworkError>) -> Void)) {
		guard let url = backendBaseURL?.appendingPathComponent("api").appendingPathComponent("movetoroom"),
			let token = token else { return }

		var request = url.request
		request.httpMethod = .post
		request.addValue(.other(value: "Token \(token.key)"), forHTTPHeaderField: .commonKey(key: .authorization))
		request.addValue(.contentType(type: .json), forHTTPHeaderField: .commonKey(key: .contentType))

		let roomInfo = ["roomID": room]
		do {
			let json = try JSONEncoder().encode(roomInfo)
			request.httpBody = json
		} catch {
			completion(.failure(.dataCodingError(specifically: error, sourceData: nil)))
			return
		}

		networkHandler.transferMahCodableDatas(with: request, completion: completion)
	}

	func getWorldmap(completion: @escaping (Result<Data, NetworkError>) -> Void) {
		guard let url = backendBaseURL?.appendingPathComponent("api").appendingPathComponent("worldmap"),
			let token = token else { return }

		var request = url.request
		request.addValue(.other(value: "Token \(token.key)"), forHTTPHeaderField: .commonKey(key: .authorization))
		request.addValue(.contentType(type: .json), forHTTPHeaderField: .commonKey(key: .contentType))

		networkHandler.transferMahDatas(with: request, completion: completion)
	}
}
