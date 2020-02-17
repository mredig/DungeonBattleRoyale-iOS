//
//  VectorExtensions.swift
//  swaap
//
//  Created by Michael Redig on 11/28/19.
//  Copyright © 2019 swaap. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGSize {
	static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
		CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
	}

	static func * (lhs: CGSize, rhs: CGSize) -> CGSize {
		CGSize(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
	}

	static func + (lhs: CGSize, rhs: CGFloat) -> CGSize {
		CGSize(width: lhs.width + rhs, height: lhs.height + rhs)
	}

	static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
		CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
	}

	var point: CGPoint {
		CGPoint(x: width, y: height)
	}
}

extension CGPoint {
	static func + (lhs: CGPoint, rhs: CGVector) -> CGPoint {
		CGPoint(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy)
	}

	static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		lhs + rhs.vector
	}

	/// multiply two points together
	static func * (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		CGPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
	}

	/// multiple both x and y by a single scalar
	static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
		lhs * CGPoint(x: rhs, y: rhs)
	}

	/// calculate the distance between points
	func distance(to point: CGPoint) -> CGFloat {
		sqrt((x - point.x) * (x - point.x) + (y - point.y) * (y - point.y))
	}

	/// Determine if the distance between points is less than or equal to a comparison value. Quicker than actually calculating the distance
	func distance(to point: CGPoint, isWithin value: CGFloat) -> Bool {
		(x - point.x) * (x - point.x) + (y - point.y) * (y - point.y) <= (value * value)
	}

	/// Since float values are sloppy, it's highly likely two values that can be considered equal will not be EXACTLY equal. Adjust the `slop` to your liking or set to `0` to disable.
	func distance(to point: CGPoint, is value: CGFloat, slop: CGFloat = 0.000001) -> Bool {
		let distanceIsh = (x - point.x) * (x - point.x) + (y - point.y) * (y - point.y)
		let valueIsh = value * value
		return abs(valueIsh - distanceIsh) <= slop
	}

	/**
	returns a point in the direction of the `toward` CGPoint, iterated at a speed of `speed` points per second. `interval`
	is the duration of time since the last frame was updated
	*/
	func stepped(toward destination: CGPoint, interval: TimeInterval, speed: CGFloat) -> CGPoint {
		let adjustedSpeed = speed * interval.cgFloat
		let vectorBetweenPoints = vector(facing: destination)

		if distance(to: destination, isWithin: adjustedSpeed) {
			return destination
		}

		return self.stepped(withNormalizedVector: vectorBetweenPoints, interval: interval, speed: speed)
	}

	/// See `stepped` variation, just mutates self with the result
	mutating func step(toward destination: CGPoint, interval: TimeInterval, speed: CGFloat) {
		self = stepped(toward: destination, interval: interval, speed: speed)
	}

	/// Steps in the direction of the vector at a rate of `speed` distance points per second. Assumes the vector is
	/// normalized - does NOT check - it is YOUR responsibility to assure that the vector is normal!
	func stepped(withNormalizedVector vector: CGVector, interval: TimeInterval, speed: CGFloat) -> CGPoint {
		let adjustedVector = vector * speed
		return self.stepped(withVector: adjustedVector, interval: interval)
	}

	/// See `stepped` variation, just mutates self with the result
	mutating func step(withNormalizedVector vector: CGVector, interval: TimeInterval, speed: CGFloat) {
		self = stepped(withNormalizedVector: vector, interval: interval, speed: speed)
	}

	/// The vector is the rate the point will step per second. This function assumes the speed is baked into the vector.
	func stepped(withVector vector: CGVector, interval: TimeInterval) -> CGPoint {
		let adjustedVector = vector * interval.cgFloat
		return self + adjustedVector
	}

	/// See `stepped` variation, just mutates self with the result
	mutating func step(withVector vector: CGVector, interval: TimeInterval) {
		self = stepped(withVector: vector, interval: interval)
	}

	var vector: CGVector {
		CGVector(dx: x, dy: y)
	}

	var size: CGSize {
		CGSize(width: x, height: y)
	}

	/// Generates a vector in the direction of `facing`, optionally (default) normalized.
	func vector(facing point: CGPoint, normalized normalize: Bool = true) -> CGVector {
		let direction = vector.inverted + point.vector
		return normalize ? direction.normalized : direction
	}
}

extension CGPoint: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(x)
		hasher.combine(y)
	}
}

extension CGAffineTransform {
	var offset: CGPoint {
		CGPoint(x: tx, y: ty)
	}
}

extension CGVector {
	static func + (lhs: CGVector, rhs: CGVector) -> CGVector {
		CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
	}

	static func * (lhs: CGVector, rhs: CGFloat) -> CGVector {
		CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs)
	}

	var normalized: CGVector {
		guard !(dx == dy && dx == 0) else { return CGVector(dx: 0, dy: 1) }
		let distance = sqrt(dx * dx + dy * dy)
		return CGVector(dx: dx / distance, dy: dy / distance)
	}

	var inverted: CGVector {
		CGVector(dx: -dx, dy: -dy)
	}

	var point: CGPoint {
		CGPoint(x: dx, y: dy)
	}

	var isNormal: Bool {
		CGPoint.zero.distance(to: self.point, is: 1.0)
	}

	/// 0 is facing right. Moves CCW
	init(fromRadian radian: CGFloat) {
		self.init(dx: cos(radian), dy: sin(radian))
	}

	/// 0 is facing right. Moves CCW
	init(fromDegree degree: CGFloat) {
		self.init(fromRadian: degree * (CGFloat.pi / 180))
	}
}

extension CGRect {
	var maxXY: CGPoint {
		CGPoint(x: maxX, y: maxY)
	}
}

extension Double {
	var cgFloat: CGFloat { CGFloat(self) }
}

extension CGFloat {
	var double: Double { Double(self) }
}
