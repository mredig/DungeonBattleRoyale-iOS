//
//  BSVBattleRoyaleTests.swift
//  BSVBattleRoyaleTests
//
//  Created by joshua kaunert on 2/4/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import XCTest
@testable import DungeonBattleRoyale

class DungeonBattleRoyaleTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func testLinkedListAddToHead() {
		let list = LinkedList<Int>()
		XCTAssertEqual(list.head?.wrappedValue, nil)
		XCTAssertEqual(list.tail?.wrappedValue, nil)
		XCTAssertEqual(list.count, 0)

		list.addToHead(value: 1)
		XCTAssertEqual(list.head?.wrappedValue, 1)
		XCTAssertEqual(list.tail?.wrappedValue, 1)
		XCTAssertEqual(list.count, 1)

		list.addToHead(value: 2)
		XCTAssertEqual(list.head?.wrappedValue, 2)
		XCTAssertEqual(list.tail?.wrappedValue, 1)
		XCTAssertEqual(list.count, 2)
	}

	func testLinkedListAddToTail() {
		let list = LinkedList<Int>()
		list.addToTail(value: 1)
		XCTAssertEqual(list.head?.wrappedValue, 1)
		XCTAssertEqual(list.tail?.wrappedValue, 1)
		XCTAssertEqual(list.count, 1)

		list.addToTail(value: 2)
		XCTAssertEqual(list.head?.wrappedValue, 1)
		XCTAssertEqual(list.tail?.wrappedValue, 2)
		XCTAssertEqual(list.count, 2)

		list.addToTail(value: 3)
		XCTAssertEqual(list.head?.wrappedValue, 1)
		XCTAssertEqual(list.tail?.wrappedValue, 3)
		XCTAssertEqual(list.count, 3)

		list.addToHead(value: 0)
		XCTAssertEqual(list.head?.wrappedValue, 0)
		XCTAssertEqual(list.tail?.wrappedValue, 3)
		XCTAssertEqual(list.count, 4)

		var node = list.head
		var array = [Int]()
		while let unwrap = node {
			array.append(unwrap.wrappedValue)
			node = node?.next
		}
		XCTAssertEqual(array, [0, 1, 2, 3])
	}

	func testLinkedListRemoveFromTail() {
		let list = LinkedList<Int>()
		list.addToTail(value: 1)
		list.addToTail(value: 2)
		list.addToTail(value: 3)
		list.addToHead(value: 0)

		var removed = list.removeFromHead()
		XCTAssertEqual(list.head?.wrappedValue, 1)
		XCTAssertEqual(list.tail?.wrappedValue, 3)
		XCTAssertEqual(removed, 0)
		XCTAssertEqual(list.count, 3)

		removed = list.removeFromTail()
		XCTAssertEqual(list.head?.wrappedValue, 1)
		XCTAssertEqual(list.tail?.wrappedValue, 2)
		XCTAssertEqual(removed, 3)
		XCTAssertEqual(list.count, 2)

		removed = list.removeFromTail()
		XCTAssertEqual(list.head?.wrappedValue, 1)
		XCTAssertEqual(list.tail?.wrappedValue, 1)
		XCTAssertEqual(removed, 2)
		XCTAssertEqual(list.count, 1)

		removed = list.removeFromTail()
		XCTAssertEqual(list.head?.wrappedValue, nil)
		XCTAssertEqual(list.tail?.wrappedValue, nil)
		XCTAssertEqual(removed, 1)
		XCTAssertEqual(list.count, 0)

		removed = list.removeFromTail()
		XCTAssertEqual(list.head?.wrappedValue, nil)
		XCTAssertEqual(list.tail?.wrappedValue, nil)
		XCTAssertEqual(removed, nil)
		XCTAssertEqual(list.count, 0)
	}

	func testLLRemoveFromHead() {
		let list = LinkedList<Int>()
		list.addToHead(value: 1)
		list.addToHead(value: 2)


		var removed = list.removeFromHead()
		XCTAssertEqual(list.head?.wrappedValue, 1)
		XCTAssertEqual(list.tail?.wrappedValue, 1)
		XCTAssertEqual(removed, 2)
		XCTAssertEqual(list.count, 1)

		removed = list.removeFromHead()
		XCTAssertEqual(list.head?.wrappedValue, nil)
		XCTAssertEqual(list.tail?.wrappedValue, nil)
		XCTAssertEqual(removed, 1)
		XCTAssertEqual(list.count, 0)

		removed = list.removeFromHead()
		XCTAssertEqual(list.head?.wrappedValue, nil)
		XCTAssertEqual(list.tail?.wrappedValue, nil)
		XCTAssertEqual(removed, nil)
		XCTAssertEqual(list.count, 0)
	}

	func testStack() {
		let stack = Stack<Int>()

		XCTAssertEqual(stack.pop(), nil)
		XCTAssertEqual(stack.count, 0)

		stack.push(0)
		XCTAssertEqual(stack.count, 1)
		stack.push(1)
		XCTAssertEqual(stack.count, 2)
		stack.push(2)
		XCTAssertEqual(stack.count, 3)
		stack.push(3)
		XCTAssertEqual(stack.count, 4)

		XCTAssertEqual(stack.peek(), 3)

		XCTAssertEqual(stack.pop(), 3)
		XCTAssertEqual(stack.count, 3)
		XCTAssertEqual(stack.peek(), 2)
		XCTAssertEqual(stack.pop(), 2)
		XCTAssertEqual(stack.count, 2)
		XCTAssertEqual(stack.pop(), 1)
		XCTAssertEqual(stack.count, 1)
		XCTAssertEqual(stack.pop(), 0)
		XCTAssertEqual(stack.count, 0)
		XCTAssertEqual(stack.pop(), nil)
		XCTAssertEqual(stack.count, 0)
	}
}
