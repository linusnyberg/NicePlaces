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
class PlacesViewController: UIViewController {

	// MARK: - Outlets

	@IBOutlet weak var tableView: UITableView!

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

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(PlacesViewController.saveAction(_:)))
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		loadPlaces()
	}

	// MARK: - Actions

	@IBAction func saveAction(_ sender: Any) {
		let placeViewController = PlaceViewController(mode: .new)
		let navigationController = UINavigationController(rootViewController: placeViewController)
		placeViewController.savePlaceHandler = {[weak self] (_ name: String?, _ latitude: Double, _ longitude: Double) -> Void in
			guard let strongSelf = self, let name = name else {
				return
			}
			strongSelf.savePlace(name: name, latitude: latitude, longitude: longitude)
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
			print("- \(place.name) at \(place.latitude),\(place.longitude)")
		}
	}

	func savePlace(name: String, latitude: Double, longitude: Double) {
		guard let placeStore = placeStore else {
			return
		}

		guard let place = placeStore.createPlace(name: name, latitude: latitude, longitude: longitude) else {
			return
		}

		places.append(place)
		tableView.reloadData()
	}

}

// MARK: - UITableViewDataSource
extension PlacesViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return places.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for:indexPath)
		let place = places[indexPath.row]
		cell.textLabel?.text = place.value(forKeyPath: "name") as? String
		return cell
	}
}

// MARK: - UITableViewDelegate
extension PlacesViewController: UITableViewDelegate{

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let navigationController = self.navigationController else {
			return
		}

		let place = places[indexPath.row]
		let placeViewModel = PlaceViewModel(place: place)

		let placeViewController = PlaceViewController(mode: .edit, viewModel: placeViewModel)

		placeViewController.savePlaceHandler = {[weak self] (_ name: String?, _ latitude: Double, _ longitude: Double) -> Void in
			guard let strongSelf = self, let name = name, let placeStore = strongSelf.placeStore else {
				return
			}
			place.name = name
			place.latitude = latitude
			place.longitude = longitude
			placeStore.updatePlace(place: place)
			tableView.reloadData()
		}

		navigationController.pushViewController(placeViewController, animated: true)
	}
}
