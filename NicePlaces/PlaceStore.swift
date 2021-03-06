//
//  PlaceStore.swift
//  NicePlaces
//
//  Created by Linus Nyberg on 2017-04-17.
//  Copyright © 2017 Linus Nyberg. All rights reserved.
//

import Foundation
import CoreData

class PlaceStore {
	var persistentContainer: NSPersistentContainer
	var placeSorter: ManualSorter<Place>

	init(withContainer persistentContainer: NSPersistentContainer) {
		self.persistentContainer = persistentContainer

		placeSorter = ManualSorter()
		placeSorter.updatedObjectHandler = {[weak self] (_ sortable: Place) -> Void in
			guard let strongSelf = self else {
				return
			}
			print("Updating order of place: \(sortable.name) => \(sortable.order)")
			strongSelf.updatePlace(place: sortable)
		}

	}

	func loadPlaces() -> [Place] {
		let managedContext = persistentContainer.viewContext

		let fetchRequest:NSFetchRequest<Place> = Place.fetchRequest()

		do {
			let places = try managedContext.fetch(fetchRequest)
			return placeSorter.checkAndSort(sortables: places)
		} catch let error as NSError {
			print("Failed fetching places: \(error), \(error.userInfo)")
		}

		return []
	}

	func createPlace(populateValues: (_ place: Place) -> Void) -> Place? {
		let managedContext = persistentContainer.viewContext

		guard let entity = NSEntityDescription.entity(forEntityName: "Place", in: managedContext) else {
			return nil
		}

		let place = Place(entity: entity, insertInto: managedContext)
		populateValues(place)

		do {
			try managedContext.save()
		} catch let error as NSError {
			print("Failed when creating place: \(error), \(error.userInfo)")
		}
		return place
	}

	func updatePlace(place: Place) {
		let managedContext = persistentContainer.viewContext
		do {
			try managedContext.save()
		} catch let error as NSError {
			print("Failed when updating place: \(error), \(error.userInfo)")
		}
	}

	func deletePlaces(places: [Place]) {
		let managedContext = persistentContainer.viewContext
		for place in places {
			managedContext.delete(place)
		}
		do {
			try managedContext.save()
		} catch let error as NSError {
			print("Failed when deleting places: \(error), \(error.userInfo)")
		}
	}

	func movePlace(places: [Place], fromIndex: Int, toIndex: Int) -> [Place] {
		return placeSorter.moveSortable(sortables: places, fromIndex: fromIndex, toIndex: toIndex)
	}
}
