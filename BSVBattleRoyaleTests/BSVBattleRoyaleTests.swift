//
//  BSVBattleRoyaleTests.swift
//  BSVBattleRoyaleTests
//
//  Created by joshua kaunert on 2/4/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import XCTest
@testable import BSVBattleRoyale

class BSVBattleRoyaleTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func testLinkedListAddToHead() {
		let list = LinkedList<Int>()
		XCTAssertEqual(list.head?.value, nil)
		XCTAssertEqual(list.tail?.value, nil)

		list.addToHead(value: 1)
		XCTAssertEqual(list.head?.value, 1)
		XCTAssertEqual(list.tail?.value, 1)

		list.addToHead(value: 2)
		XCTAssertEqual(list.head?.value, 2)
		XCTAssertEqual(list.tail?.value, 1)
	}

	func testLinkedListAddToTail() {
		let tailList = LinkedList<Int>()
		tailList.addToTail(value: 1)
		XCTAssertEqual(tailList.head?.value, 1)
		XCTAssertEqual(tailList.tail?.value, 1)

		tailList.addToTail(value: 2)
		XCTAssertEqual(tailList.head?.value, 1)
		XCTAssertEqual(tailList.tail?.value, 2)

		tailList.addToTail(value: 3)
		XCTAssertEqual(tailList.head?.value, 1)
		XCTAssertEqual(tailList.tail?.value, 3)

		tailList.addToHead(value: 0)
		XCTAssertEqual(tailList.head?.value, 0)
		XCTAssertEqual(tailList.tail?.value, 3)

		var node = tailList.head
		var array = [Int]()
		while let unwrap = node {
			array.append(unwrap.value)
			node = node?.next
		}
		XCTAssertEqual(array, [0, 1, 2, 3])
	}

	func testLinkedListRemoveFromTail() {
		let tailList = LinkedList<Int>()
		tailList.addToTail(value: 1)
		tailList.addToTail(value: 2)
		tailList.addToTail(value: 3)
		tailList.addToHead(value: 0)

		var removed = tailList.removeFromHead()
		XCTAssertEqual(tailList.head?.value, 1)
		XCTAssertEqual(tailList.tail?.value, 3)
		XCTAssertEqual(removed, 0)

		removed = tailList.removeFromTail()
		XCTAssertEqual(tailList.head?.value, 1)
		XCTAssertEqual(tailList.tail?.value, 2)
		XCTAssertEqual(removed, 3)

		removed = tailList.removeFromTail()
		XCTAssertEqual(tailList.head?.value, 1)
		XCTAssertEqual(tailList.tail?.value, 1)
		XCTAssertEqual(removed, 2)

		removed = tailList.removeFromTail()
		XCTAssertEqual(tailList.head?.value, nil)
		XCTAssertEqual(tailList.tail?.value, nil)
		XCTAssertEqual(removed, 1)

		removed = tailList.removeFromTail()
		XCTAssertEqual(tailList.head?.value, nil)
		XCTAssertEqual(tailList.tail?.value, nil)
		XCTAssertEqual(removed, nil)

	}

	func testLLRemoveFromHead() {
		let list = LinkedList<Int>()
		list.addToHead(value: 1)
		list.addToHead(value: 2)


		var removed = list.removeFromHead()
		XCTAssertEqual(list.head?.value, 1)
		XCTAssertEqual(list.tail?.value, 1)
		XCTAssertEqual(removed, 2)

		removed = list.removeFromHead()
		XCTAssertEqual(list.head?.value, nil)
		XCTAssertEqual(list.tail?.value, nil)
		XCTAssertEqual(removed, 1)

		removed = list.removeFromHead()
		XCTAssertEqual(list.head?.value, nil)
		XCTAssertEqual(list.tail?.value, nil)
		XCTAssertEqual(removed, nil)
	}
}
