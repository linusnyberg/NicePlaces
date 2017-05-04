//
//  ViewController.swift
//  NicePlaces
//
//  Created by Linus Nyberg on 2017-04-05.
//  Copyright © 2017 Linus Nyberg. All rights reserved.
//

import UIKit
import CoreData

/// The list of saved places
class PlacesViewController: UITableViewController {

	// MARK: - Outlets

	// MARK: - Properties

	var places: [Place] = []

	lazy var placeStore: PlaceStore? = {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
			return nil
		}

		return PlaceStore(withContainer: appDelegate.persistentContainer)
	}()

	// MARK: - Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

		title = "Places"
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlaceCell")

		tableView.delegate = self

		navigationItem.rightBarButtonItem = self.editButtonItem
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		loadPlaces()

		let saveItem = UIBarButtonItem(title: "Save This Place", style: .plain, target: self, action: #selector(PlacesViewController.saveAction(_:)))
		self.navigationController?.isToolbarHidden = false
		self.toolbarItems = [saveItem]
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		self.navigationController?.isToolbarHidden = true
	}

	// MARK: - Actions

	@IBAction func saveAction(_ sender: Any) {
		let placeViewController = PlaceViewController(mode: .new)
		let navigationController = UINavigationController(rootViewController: placeViewController)
		placeViewController.savePlaceHandler = {[weak self] (_ viewModel: PlaceViewModel) -> Void in
			guard let strongSelf = self else {
				return
			}
			strongSelf.savePlace(viewModel: viewModel)
		}
		self.present(navigationController, animated: true, completion: nil)
	}

	// MARK: - Helpers

	func loadPlaces() {
		guard let placeStore = placeStore else {
			return
		}

		places = placeStore.loadPlaces()

		print("Loaded places:")
		for place in places {
			print("- \(place.name) (\(place.geocoderName)) at \(place.latitude),\(place.longitude) (order:\(place.order))")
		}
	}

	func savePlace(viewModel: PlaceViewModel) {
		guard let placeStore = placeStore else {
			return
		}

		guard let place = placeStore.createPlace(populateValues: { (place: Place) in
			viewModel.copyDataToPlace(place: place)
		}) else {
			return
		}

		places.append(place)
		tableView.reloadData()
	}

	func deletePlaces(placesToDelete: [Place]) {
		guard let placeStore = placeStore else {
			return
		}
		placeStore.deletePlaces(places: placesToDelete)
		for place in placesToDelete {
			guard let index = places.index(of: place) else {
				continue
			}
			places.remove(at: index)
		}
	}
}

// MARK: - UITableViewDataSource
extension PlacesViewController {

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return places.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for:indexPath)
		let place = places[indexPath.row]

		var names = Array<String>()
		if (place.name.characters.count > 0) {
			names.append(place.name)
		}
		if (place.geocoderName.characters.count > 0) {
			names.append(place.geocoderName)
		}
		if (names.count == 1) {
			cell.textLabel?.text = "\(names[0])"
		} else if (names.count == 2) {
			cell.textLabel?.text = "\(names[0]) (\(names[1]))"
		} else {
			cell.textLabel?.text = "?"
		}

		return cell
	}

	override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return true
	}

	override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		guard let placeStore = placeStore else {
			return
		}
		places = placeStore.movePlace(places: places, fromIndex: sourceIndexPath.row, toIndex: destinationIndexPath.row)
	}
}

// MARK: - UITableViewDelegate
extension PlacesViewController{

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let navigationController = self.navigationController else {
			return
		}

		let place = places[indexPath.row]
		let placeViewModel = PlaceViewModel(place: place)

		let placeViewController = PlaceViewController(mode: .edit, viewModel: placeViewModel)

		placeViewController.savePlaceHandler = {[weak self] (_ viewModel: PlaceViewModel) -> Void in
			guard let strongSelf = self, let placeStore = strongSelf.placeStore else {
				return
			}
			viewModel.copyDataToPlace(place: place)
			placeStore.updatePlace(place: place)
			tableView.reloadData()
		}

		navigationController.pushViewController(placeViewController, animated: true)
	}

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		let place = places[indexPath.row]

		if (editingStyle == .delete) {
			deletePlaces(placesToDelete: [place])
			tableView.beginUpdates()
			tableView.deleteRows(at: [indexPath], with: .automatic)
			tableView.endUpdates()
		}
	}
}
