//
//  LinkedList.swift
//  BSVBattleRoyale
//
//  Created by Michael Redig on 2/4/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import Foundation

class LinkedList<T> {
	class Node<T> {
		let value: T
		var next: Node<T>?
		var previous: Node<T>?

		init(value: T, next: Node?, previous: Node?) {
			self.value = value
			self.next = next
			self.previous = previous
		}

		func insertBefore(value: T) {
			let newNode = Node(value: value, next: self, previous: previous)
			previous = newNode
		}

		func insertAfter(value: T) {
			let newNode = Node(value: value, next: next, previous: self)
			next = newNode
		}
	}

	var head: Node<T>?
	var tail: Node<T>?
	var count: Int = 0

	func addToHead(value: T) {
		let newNode = Node(value: value, next: head, previous: nil)
		head?.previous = newNode
		head = newNode
		if tail == nil {
			tail = newNode
		}
	}

	func addToTail(value: T) {
		let newNode = Node(value: value, next: nil, previous: tail)
		tail?.next = newNode
		tail = newNode
		if head == nil {
			head = newNode
		}
	}

	func removeFromHead() -> T? {
		let value = head?.value
		if head === tail {
			head = nil
			tail = nil
		}
		head = head?.next
		return value
	}

	func removeFromTail() -> T? {
		let value = tail?.value
		if head === tail {
			head = nil
			tail = nil
		}
		tail = tail?.previous
		return value
	}
}