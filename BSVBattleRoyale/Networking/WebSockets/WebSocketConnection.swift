//
//  WebSocketConnection.swift
//  BSVBattleRoyale
//
//  Created by joshua kaunert on 2/4/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import Foundation
import Combine

protocol WebSocketConnection {
    func send(text: String)
    func send(data: Data)
    func connect()
    func disconnect()
    var delegate: WebSocketConnectionDelegate? {
        get
        set
    }
}

protocol WebSocketConnectionDelegate {
    func onConnected(connection: WebSocketConnection)
    func onDisconnected(connection: WebSocketConnection, error: Error?)
    func onError(connection: WebSocketConnection, error: Error)
    func onMessage(connection: WebSocketConnection, text: String)
    func onMessage(connection: WebSocketConnection, data: Data)
}

class WebSocketTaskConnection: NSObject, WebSocketConnection, URLSessionWebSocketDelegate {
    var delegate: WebSocketConnectionDelegate?
    var webSocketTask: URLSessionWebSocketTask!
    var urlSession: URLSession!
    let delegateQueue = OperationQueue()

	private var connected = false
    
    init(url: URL) {
        super.init()
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: delegateQueue)
        webSocketTask = urlSession.webSocketTask(with: url)
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
		connected = true
        self.delegate?.onConnected(connection: self)
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
		if connected {
			connected = false
			self.delegate?.onDisconnected(connection: self, error: nil)
		}
	}
    
    func connect() {
        webSocketTask.resume()
        
        listen()
    }
    
    func disconnect() {
        webSocketTask.cancel(with: .goingAway, reason: nil)
		if connected {
			connected = false
			self.delegate?.onDisconnected(connection: self, error: nil)
		}
    }
    
    func listen()  {
        webSocketTask.receive { result in
            switch result {
            case .failure(let error):
                self.handleError(error)
            case .success(let message):
                switch message {
                case .string(let text):
                    self.delegate?.onMessage(connection: self, text: text)
                case .data(let data):
                    self.delegate?.onMessage(connection: self, data: data)
                @unknown default:
                    fatalError()
                }
                
                self.listen()
            }
        }
    }
    
    func send(text: String) {
		guard connected else { return }
        webSocketTask.send(URLSessionWebSocketTask.Message.string(text)) { error in
            if let error = error {
                self.handleError(error)
            }
        }
    }
    
    func send(data: Data) {
		guard connected else { return }
        webSocketTask.send(URLSessionWebSocketTask.Message.data(data)) { error in
            if let error = error {
                self.handleError(error)
            }
        }
    }

	private func handleError(_ error: Error) {
		delegate?.onError(connection: self, error: error)
		let code = (error as NSError).code
		if code == 57 || code == 54 {
			disconnect()
		}
	}
}

