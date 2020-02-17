//
//  BSVBattleRoyaleTests.swift
//  BSVBattleRoyaleTests
//
//  Created by joshua kaunert on 2/4/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import XCTest
@testable import DungeonBattleRoyale

class VectorExtensionsTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func testCGPointTowardStepping() {
		let pointA = CGPoint.zero
		let pointB = CGPoint(x: 0, y: 100)
		let pointC = CGPoint(x: 100, y: -100)
		let pointD = CGPoint(x: 1, y: 0)

		// tests that time intervals work
		var mutPoint = pointA
		let iterations: TimeInterval = 60
		for _ in 0..<Int(iterations) {
			mutPoint = mutPoint.stepped(toward: pointB, interval: 1/iterations, speed: 1)
		}
		XCTAssertEqual(mutPoint.x, 0, accuracy: 0.00001)
		XCTAssertEqual(mutPoint.y, 1, accuracy: 0.00001)

		// tests that time intervals work v2
		mutPoint = pointA
		for _ in 0..<Int(iterations) {
			mutPoint = mutPoint.stepped(toward: pointB, interval: 1/iterations, speed: 50)
		}
		XCTAssertEqual(mutPoint.x, 0, accuracy: 0.00001)
		XCTAssertEqual(mutPoint.y, 50, accuracy: 0.00001)

		// tests going to a different quadrant
		mutPoint = pointA
		for _ in 0..<Int(iterations) {
			mutPoint = mutPoint.stepped(toward: pointC, interval: 1/iterations, speed: 1)
		}
		XCTAssertEqual(mutPoint.x, 0.7071067, accuracy: 0.00001)
		XCTAssertEqual(mutPoint.y, -0.7071067, accuracy: 0.00001)

		// should land exactly on destination
		mutPoint = pointA
		for _ in 0..<Int(iterations) {
			mutPoint.step(toward: pointD, interval: 1/iterations, speed: 1)
		}
		XCTAssertEqual(mutPoint.x, 1, accuracy: 0.00001)
		XCTAssertEqual(mutPoint.y, 0, accuracy: 0.00001)

		// makes to destination halfway through. shouldn't keep going
		mutPoint = pointA
		for _ in 0..<Int(iterations * 2) {
			mutPoint.step(toward: pointD, interval: 1/iterations, speed: 1)
		}
		XCTAssertEqual(mutPoint.x, 1, accuracy: 0.00001)
		XCTAssertEqual(mutPoint.y, 0, accuracy: 0.00001)

		// doesn't make to destination
		mutPoint = pointA
		for _ in 0..<Int(iterations/2) {
			mutPoint.step(toward: pointD, interval: 1/iterations, speed: 1)
		}
		XCTAssertEqual(mutPoint.x, 0.5, accuracy: 0.00001)
		XCTAssertEqual(mutPoint.y, 0, accuracy: 0.00001)
	}

	func testCGPointVectorStepping() {
		let pointA = CGPoint.zero
		let pointB = CGPoint(x: 0, y: 100)
		let pointC = CGPoint(x: 100, y: -100)

		// tests that vectors move toward the right direction
		var mutPoint = pointA
		let vector1 = pointA.vector(facing: pointB)
		let iterations: TimeInterval = 60
		for _ in 0..<Int(iterations) {
			mutPoint = mutPoint.stepped(withNormalizedVector: vector1, interval: 1/iterations, speed: 1)
		}
		XCTAssertEqual(mutPoint.x, 0, accuracy: 0.00001)
		XCTAssertEqual(mutPoint.y, 1, accuracy: 0.00001)

		// tests that vectors move toward the right direction at the expected rate
		mutPoint = pointA
		let vector2 = pointA.vector(facing: pointC)
		for _ in 0..<Int(iterations) {
			mutPoint.step(withNormalizedVector: vector2, interval: 1/iterations, speed: 1)
		}
		XCTAssertEqual(mutPoint.x, 0.7071067, accuracy: 0.00001)
		XCTAssertEqual(mutPoint.y, -0.7071067, accuracy: 0.00001)

		// tests that vectors move toward the right direction  at the rate of the vector itself
		mutPoint = pointA
		let vector3 = pointA.vector(facing: pointB, normalized: false)
		for _ in 0..<Int(iterations) {
			mutPoint = mutPoint.stepped(withVector: vector3, interval: 1/iterations)
		}
		XCTAssertEqual(mutPoint.x, pointB.x, accuracy: 0.00001)
		XCTAssertEqual(mutPoint.y, pointB.y, accuracy: 0.00001)

		// tests that vectors move toward the right direction  at the rate of the vector itself v2
		mutPoint = pointA
		let vector4 = pointA.vector(facing: pointC, normalized: false)
		for _ in 0..<Int(iterations) {
			mutPoint.step(withVector: vector4, interval: 1/iterations)
		}
		XCTAssertEqual(mutPoint.x, pointC.x, accuracy: 0.00001)
		XCTAssertEqual(mutPoint.y, pointC.y, accuracy: 0.00001)

	}

	func testCGPointVectorStuff() {
		let pointA = CGPoint.zero
		let pointB = CGPoint(x: 0, y: 100)
		let pointC = CGPoint(x: 100, y: -100)

		// confirms the vector is correct
		let facing1 = pointA.vector(facing: pointB)
		let facing2 = pointA.vector(facing: pointB, normalized: false)
		XCTAssertEqual(facing1.dx, 0, accuracy: 0.00001)
		XCTAssertEqual(facing1.dy, 1, accuracy: 0.00001)
		XCTAssertEqual(facing2.dx, 0, accuracy: 0.00001)
		XCTAssertEqual(facing2.dy, 100, accuracy: 0.00001)

		// confirms the vector is correct
		let facing3 = pointA.vector(facing: pointC)
		let facing4 = pointA.vector(facing: pointC, normalized: false)
		XCTAssertEqual(facing3.dx, 0.7071067, accuracy: 0.00001)
		XCTAssertEqual(facing3.dy, -0.7071067, accuracy: 0.00001)
		XCTAssertEqual(facing4.dx, 100, accuracy: 0.00001)
		XCTAssertEqual(facing4.dy, -100, accuracy: 0.00001)
	}

	func testCGVectorUtilities() {
		let vec = CGVector(dx: 34, dy: 8.432)
		let point = vec.point

		XCTAssertEqual(vec.dx, point.x)
		XCTAssertEqual(vec.dy, point.y)

		let notNormal = CGVector(dx: 1, dy: 1)
		XCTAssertEqual(notNormal.isNormal, false)
		let normalized = notNormal.normalized
		XCTAssertEqual(normalized.isNormal, true)

		let normalVec = CGVector(dx: 0.7071067, dy: 0.7071067)
		XCTAssertEqual(normalVec.isNormal, true)

		let one = CGVector(dx: 1, dy: 1)
		let two = CGVector(dx: 2, dy: 2)
		let three = one + two
		XCTAssertEqual(three, CGVector(dx: 3, dy: 3))

		let six = two * 3
		XCTAssertEqual(six, CGVector(dx: 6, dy: 6))
	}
}
