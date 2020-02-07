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
        guard let url = backendBaseURL?.appendingPathComponent("api")
            .appendingPathComponent("auth")
            .appendingPathComponent("registration", isDirectory: true) else { return }
        
        var request = url.request
        request.httpMethod = .post
        request.expectedResponseCodes = Set(200...299)
        request.addValue(.contentType(type: .json), forHTTPHeaderField: .commonKey(key: .contentType))

        let user = User(username: username, password: nil, password1: password, password2: password)
        do {
            request.httpBody = try JSONEncoder().encode(user)
        } catch {
            completion(error)
            return
        }
        
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
    
    
    func login(with username: String, password: String, completion: @escaping (Error?) -> Void) {
        guard let url = backendBaseURL?.appendingPathComponent("api")
            .appendingPathComponent("auth")
            .appendingPathComponent("login", isDirectory: true) else { return }
        
        var request = url.request
        request.httpMethod = .post
        request.expectedResponseCodes = Set(200...299)
        request.addValue(.contentType(type: .json), forHTTPHeaderField: .commonKey(key: .contentType))
        
        let user = User(username: username, password: password, password1: nil, password2: nil)
        do {
            request.httpBody = try JSONEncoder().encode(user)
        } catch {
            completion(error)
            return
        }
        
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
		guard let url = backendBaseURL?.appendingPathComponent("api").appendingPathComponent("init"),
			let token = token else { return }

		var request = url.request
		request.httpMethod = .post
		request.addValue(.other(value: "Token \(token.key)"), forHTTPHeaderField: .commonKey(key: .authorization))
		request.addValue(.contentType(type: .json), forHTTPHeaderField: .commonKey(key: .contentType))

		let toServer = ["player_avatar": selectedAvatar.rawValue]
		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: toServer, options: [])
		} catch {
			completion(.failure(.dataCodingError(specifically: error, sourceData: nil)))
			return
		}

		networkHandler.transferMahCodableDatas(with: request, completion: completion)
	}

	func fetchPlayerInfo(for id: String, completion: @escaping ((Result<PlayerInfo, NetworkError>) -> Void)) -> URLSessionDataTask? {
		guard let url = backendBaseURL?.appendingPathComponent("api").appendingPathComponent("playerinfo"),
			let token = token else { return nil }

		var request = url.request
		request.httpMethod = .post
		request.addValue(.other(value: "Token \(token.key)"), forHTTPHeaderField: .commonKey(key: .authorization))
		request.addValue(.contentType(type: .json), forHTTPHeaderField: .commonKey(key: .contentType))

		let toServer = ["id": id]
		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: toServer, options: [])
		} catch {
			completion(.failure(.dataCodingError(specifically: error, sourceData: nil)))
			return nil
		}

		return networkHandler.transferMahCodableDatas(with: request, completion: completion)
	}

	func movePlayer(to room: Int, completion: @escaping ((Result<PlayerMove, NetworkError>) -> Void)) {
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

	func getWorldmap(completion: @escaping (Result<RoomCollection, NetworkError>) -> Void) {
		guard let url = backendBaseURL?.appendingPathComponent("api").appendingPathComponent("worldmap"),
			let token = token else { return }

		var request = url.request
		request.addValue(.other(value: "Token \(token.key)"), forHTTPHeaderField: .commonKey(key: .authorization))
		request.addValue(.contentType(type: .json), forHTTPHeaderField: .commonKey(key: .contentType))

		networkHandler.transferMahCodableDatas(with: request, completion: completion)
	}
}
