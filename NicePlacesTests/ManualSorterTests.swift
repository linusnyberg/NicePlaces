//
//  ManualSorterTests.swift
//  NicePlaces
//
//  Created by Linus Nyberg on 2017-04-30.
//  Copyright © 2017 Linus Nyberg. All rights reserved.
//

import XCTest
@testable import NicePlaces

class SimpleSortable: ManuallySortable {
	var name: String
	var order: Double

	init(withName name: String, order: Double) {
		self.name = name
		self.order = order
	}
}

class ManualSorterTests: XCTestCase {
    
    func testEmptySortables_shouldRemainEmpty() {
		let sortables = [SimpleSortable]()
		let manualSorter = ManualSorter<SimpleSortable>()
		let sorted = manualSorter.checkAndSort(sortables: sortables)
		XCTAssert(sorted.count == 0)
    }

	func testRepairingInvalidOrderValues() {
		let invalid1 = SimpleSortable(withName: "B", order: 1.0)
		let invalid2 = SimpleSortable(withName: "C", order: 1.0)

		var sortables = [SimpleSortable]()
		sortables.append(SimpleSortable(withName: "A", order: 0.0))
		sortables.append(invalid1)
		sortables.append(invalid2)
		sortables.append(SimpleSortable(withName: "D", order: 2.0))

		let manualSorter = ManualSorter<SimpleSortable>()
		let sorted = manualSorter.checkAndSort(sortables: sortables)

		XCTAssert(sorted.count == 4)
		XCTAssert(!manualSorter.hasSameOrderValue(first: invalid1, second: invalid2))
	}

	func testMovingUpwards() {
		let a = SimpleSortable(withName: "A", order: 1.0)
		let b = SimpleSortable(withName: "B", order: 2.0)
		let c = SimpleSortable(withName: "C", order: 3.0)
		let sortables = [a, b, c]

		let manualSorter = ManualSorter<SimpleSortable>()
		let sorted = manualSorter.moveSortable(sortables: sortables, fromIndex: 2, toIndex: 1)

		for sortable in sorted {
			print("- \(sortable.name): \(sortable.order)")
		}
		XCTAssert(sorted.count == 3)
		XCTAssert(c.order < b.order)
		XCTAssert(c.order > a.order)
		XCTAssert(sorted.first! === a)
		XCTAssert(sorted.last! === b)
	}

	func testMovingToTop() {
		let a = SimpleSortable(withName: "A", order: 1.0)
		let b = SimpleSortable(withName: "B", order: 2.0)
		let c = SimpleSortable(withName: "C", order: 3.0)
		let sortables = [a, b, c]

		let manualSorter = ManualSorter<SimpleSortable>()
		let sorted = manualSorter.moveSortable(sortables: sortables, fromIndex: 2, toIndex: 0)

		for sortable in sorted {
			print("- \(sortable.name): \(sortable.order)")
		}
		XCTAssert(sorted.count == 3)
		XCTAssert(c.order < b.order)
		XCTAssert(c.order < a.order)
		XCTAssert(sorted.first! === c)
		XCTAssert(sorted.last! === b)
	}

	func testMovingDownwards() {
		let a = SimpleSortable(withName: "A", order: 1.0)
		let b = SimpleSortable(withName: "B", order: 2.0)
		let c = SimpleSortable(withName: "C", order: 3.0)
		let sortables = [a, b, c]

		let manualSorter = ManualSorter<SimpleSortable>()
		let sorted = manualSorter.moveSortable(sortables: sortables, fromIndex: 0, toIndex: 1)

		for sortable in sorted {
			print("- \(sortable.name): \(sortable.order)")
		}
		XCTAssert(sorted.count == 3)
		XCTAssert(a.order > b.order)
		XCTAssert(a.order < c.order)
		XCTAssert(sorted.first! === b)
		XCTAssert(sorted.last! === c)
	}

	func testMovingToBottom() {
		let a = SimpleSortable(withName: "A", order: 1.0)
		let b = SimpleSortable(withName: "B", order: 2.0)
		let c = SimpleSortable(withName: "C", order: 3.0)
		let sortables = [a, b, c]

		let manualSorter = ManualSorter<SimpleSortable>()
		let sorted = manualSorter.moveSortable(sortables: sortables, fromIndex: 0, toIndex: 2)

		for sortable in sorted {
			print("- \(sortable.name): \(sortable.order)")
		}
		XCTAssert(sorted.count == 3)
		XCTAssert(a.order > b.order)
		XCTAssert(a.order > c.order)
		XCTAssert(sorted.first! === b)
		XCTAssert(sorted.last! === a)
	}

}
