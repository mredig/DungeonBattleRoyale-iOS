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
	var token: Bearer?
	let networkHandler = NetworkHandler.default
	var selectedAvatar: Avatar = .yellowMonster

	func register(with username: String, password: String, completion: @escaping (Error?) -> Void) {
		guard let url = backendBaseURL?.appendingPathComponent("register") else { return }

		var request = url.request
		request.httpMethod = .post
		request.expectedResponseCodes = Set(200...299)
		request.addValue(.contentType(type: .json), forHTTPHeaderField: .commonKey(key: .contentType))

		let user = User(username: username, password: password, passwordVerify: password)
		do {
			request.httpBody = try JSONEncoder().encode(user)
		} catch {
			completion(error)
			return
		}

		networkHandler.transferMahCodableDatas(with: request) { (result: Result<PlayerInit, NetworkError>) in
			switch result {
			case .success:
				completion(nil)
			case .failure(let error):
				completion(error)
			}
		}
	}


	func login(with username: String, password: String, completion: @escaping (Error?) -> Void) {
		guard let url = backendBaseURL?.appendingPathComponent("login") else { return }

		var request = url.request
		request.httpMethod = .post
		request.expectedResponseCodes = Set(200...299)
		request.addValue(.contentType(type: .json), forHTTPHeaderField: .commonKey(key: .contentType))

		let user = User(username: username, password: password, passwordVerify: nil)
		request.encodeData(user)

		networkHandler.transferMahCodableDatas(with: request) { (result: Result<Bearer, NetworkError>) in
			do {
				self.token = try result.get()
				completion(nil)
			} catch {
				completion(error)
				return
			}
		}
	}

	func initializePlayer(completion: @escaping ((Result<PlayerInit, NetworkError>) -> Void)) {
		guard let url = backendBaseURL?.appendingPathComponent("initialize"),
			let token = token else { return }

		var request = url.request
		request.httpMethod = .post
		request.addValue(.other(value: "Bearer \(token.token)"), forHTTPHeaderField: .commonKey(key: .authorization))
		request.addValue(.contentType(type: .json), forHTTPHeaderField: .commonKey(key: .contentType))

		let toServer = ["playerAvatar": selectedAvatar.rawValue]
		request.encodeData(toServer)

		networkHandler.transferMahCodableDatas(with: request, completion: completion)
	}

	func fetchPlayerInfo(for id: String, completion: @escaping ((Result<PlayerInfo, NetworkError>) -> Void)) -> URLSessionDataTask? {
		guard let url = backendBaseURL?.appendingPathComponent("playerinfo"),
			let token = token else { return nil }

		var request = url.request
		request.httpMethod = .post
		request.addValue(.other(value: "Bearer \(token.token)"), forHTTPHeaderField: .commonKey(key: .authorization))
		request.addValue(.contentType(type: .json), forHTTPHeaderField: .commonKey(key: .contentType))

		let toServer = ["playerID": id]
		request.encodeData(toServer)

		return networkHandler.transferMahCodableDatas(with: request, completion: completion)
	}

	func movePlayer(to room: Int, completion: @escaping ((Result<PlayerMove, NetworkError>) -> Void)) {
		guard let url = backendBaseURL?.appendingPathComponent("move"),
			let token = token else { return }

		var request = url.request
		request.httpMethod = .post
		request.addValue(.other(value: "Bearer \(token.token)"), forHTTPHeaderField: .commonKey(key: .authorization))
		request.addValue(.contentType(type: .json), forHTTPHeaderField: .commonKey(key: .contentType))

		let roomInfo = ["roomID": room]
		request.encodeData(roomInfo)

		networkHandler.transferMahCodableDatas(with: request, completion: completion)
	}

	func getWorldmap(completion: @escaping (Result<RoomCollection, NetworkError>) -> Void) {
		guard let url = backendBaseURL?.appendingPathComponent("overworld"),
			let token = token else { return }

		var request = url.request
		request.addValue(.other(value: "Bearer \(token.token)"), forHTTPHeaderField: .commonKey(key: .authorization))
		request.addValue(.contentType(type: .json), forHTTPHeaderField: .commonKey(key: .contentType))

		networkHandler.transferMahCodableDatas(with: request, completion: completion)
	}
}
