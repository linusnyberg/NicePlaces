//
//  ManualSorter.swift
//  NicePlaces
//
//  Created by Linus Nyberg on 2017-04-30.
//  Copyright © 2017 Linus Nyberg. All rights reserved.
//

import Foundation

/// Sorting functions for objects that adhere to the `ManuallySortable` protocol.
/// Whenever objects' order properties are updated, the `updatedObjectHandler` will be called,
/// which could be a good time to save the object to the database for example.
class ManualSorter<Sortable: ManuallySortable> {

	var updatedObjectHandler: (_ sortable: Sortable) -> Void = {_ in }

	// MARK: - Public methods

	/// Returns the sorted array of sortables, by making sure they have valid order values.
	func checkAndSort(sortables: [Sortable]) -> [Sortable] {
		return sort(sortables: sanityCheckOrder(sortables: sortables))
	}

	/// Moves the sortable at `fromIndex` to the given location and performs the resulting calls `updatedObjectHandler` to make that happen.
	func moveSortable(sortables: [Sortable], fromIndex: Int, toIndex: Int) -> [Sortable] {
		assert(fromIndex < sortables.count)
		assert(fromIndex >= 0)
		assert(toIndex < sortables.count)
		assert(toIndex >= 0)

		if (fromIndex < toIndex) {
			// Move down
			if (toIndex == sortables.count - 1) {
				// Move to the bottom
				guard let lastObject = sortables.last else {
					return sortables
				}
				let moveObject = sortables[fromIndex]
				updateObjectOrder(sortable: moveObject, newOrder: lastObject.order + 1.0)
			} else {
				// Move to a place before some other object
				let prevObject = sortables[toIndex]
				let nextObject = sortables[toIndex + 1]
				let moveObject = sortables[fromIndex]
				let newOrderValue = (prevObject.order + nextObject.order) / 2.0
				updateObjectOrder(sortable: moveObject, newOrder: newOrderValue)
			}
		} else {
			// Move up
			if (toIndex == 0) {
				// Move to the top
				guard let firstObject = sortables.first else {
					return sortables
				}
				let moveObject = sortables[fromIndex]
				updateObjectOrder(sortable: moveObject, newOrder: firstObject.order - 1.0)
			} else {
				// Move to a place after some other object
				let prevObject = sortables[toIndex - 1]
				let nextObject = sortables[toIndex]
				let moveObject = sortables[fromIndex]
				let newOrderValue = (prevObject.order + nextObject.order) / 2.0
				updateObjectOrder(sortable: moveObject, newOrder: newOrderValue)
			}
		}
		return checkAndSort(sortables: sortables)
	}

	/// Determines if the two sortables have the same order value or not.
	/// Only public for unit testing purposes.
	func hasSameOrderValue(first: Sortable, second: Sortable) -> Bool {
		// Note: Compare with delta, since it's floating point:
		if fabs(first.order.distance(to: second.order)) <= 1e-15 {
			// It has the same order value as the previous item.
			return true
		}
		return false
	}

	// MARK: - Private helpers

	/// Only sorts the given sortables.
	private func sort(sortables: [Sortable]) -> [Sortable] {
		return sortables.sorted(by: { (first: Sortable, second: Sortable) -> Bool in
			return first.order < second.order
		})
	}

	/// Makes sure no two order values are the same.
	private func sanityCheckOrder(sortables: [Sortable]) -> [Sortable] {
		if hasInvalidOrder(sortables: sortables) {
			return initOrder(sortables: sortables)
		}
		return sortables
	}

	/// Checks if two order values are the same.
	private func hasInvalidOrder(sortables: [Sortable]) -> Bool {
		let sortedSortables = sort(sortables: sortables)
		for (index, sortable) in sortedSortables.enumerated() {
			if index == 0 {
				continue
			}

			let prevSortable = sortedSortables[index - 1]
			if hasSameOrderValue(first: sortable, second: prevSortable) {
				return true
			}
		}
		return false
	}

	/// Initializes the order values on all given objects. Tries to respect the current order if possible.
	private func initOrder(sortables: [Sortable]) -> [Sortable] {
		// First sort the array. That will make the final order resemble the current one if possible.
		// Then just assign new order values to all objects.
		var order = 1.0
		for sortable in sort(sortables: sortables) {
			updateObjectOrder(sortable: sortable, newOrder: order)
			order += 1.0
		}
		return sort(sortables: sortables)
	}
	
	/// Updates the order on the object and calls the update handler.
	private func updateObjectOrder(sortable: Sortable, newOrder: Double) {
		var mutableSortable = sortable
		mutableSortable.order = newOrder
		updatedObjectHandler(mutableSortable)
	}
}
