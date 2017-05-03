//
//  SavePlaceViewController.swift
//  NicePlaces
//
//  Created by Linus Nyberg on 2017-04-05.
//  Copyright © 2017 Linus Nyberg. All rights reserved.
//

import UIKit
import MapKit

/**
The view controller for a single place.
Is used both for saving new places and for viewing/editing existing ones.
*/
class PlaceViewController: UIViewController {

	enum Mode {
		case new, edit
	}

	// MARK: - Properties

	fileprivate var mode: Mode = .new
	fileprivate var viewModel: PlaceViewModel = PlaceViewModel()

	var savePlaceHandler: (_ name: String?, _ latitude: Double, _ longitude: Double) -> Void = {_ in }

	lazy var textField: UITextField! = {
		let textField = UITextField()
		textField.placeholder = "Give the place a name or title"
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.borderStyle = .roundedRect
		textField.textAlignment = .center
		textField.delegate = self
		return textField
	}()

	lazy var mapView: MKMapView! = {
		let mapView = MKMapView()
		mapView.translatesAutoresizingMaskIntoConstraints = false
		mapView.delegate = self
		return mapView
	}()

	var locationManager = CLLocationManager()

	// MARK: - Lifecycle

	convenience init(mode: Mode, viewModel: PlaceViewModel) {
		self.init(nibName: nil, bundle: nil)
		self.mode = mode
		self.viewModel = viewModel
	}

	convenience init(mode: Mode) {
		self.init(nibName: nil, bundle: nil)
		self.mode = mode
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		locationManager.delegate = self

		view.backgroundColor = UIColor.white

		view.addSubview(textField)
		view.addSubview(mapView)

		addTextFieldConstraints()
		addMapViewConstraints()

		let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(PlaceViewController.dropPinAction))
		longPressGR.minimumPressDuration = 1.0
		mapView.addGestureRecognizer(longPressGR)

		switch mode {
		case .new:
			navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(PlaceViewController.dismissAction))
			navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(PlaceViewController.saveAction))
		default:
			textField.isEnabled = false
			navigationItem.rightBarButtonItem = self.editButtonItem
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if mode == .new {
			tryUpdatingLocation()
		} else {
			updatePinnedLocation()
			textField.text = viewModel.name
		}
	}

	// MARK: - UIViewController

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		textField.isEnabled = editing

		if !editing {
			savePlace()
		}
	}

	// MARK: - Constraints

	func addTextFieldConstraints() {
		textField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		textField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
		textField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100.0).isActive = true
	}

	func addMapViewConstraints() {
		mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.0).isActive = true
		mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10.0).isActive = true
		mapView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20.0).isActive = true
		mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120.0).isActive = true
	}

	// MARK: - Actions

	func saveAction() {
		savePlace()
		self.dismiss(animated: true, completion: nil)
	}

	func editAction() {
		self.isEditing = true
	}

	func dismissAction() {
		self.dismiss(animated: true, completion: nil)
	}

	func dropPinAction(gestureRecognizer: UIGestureRecognizer) {
		if mode != .new && !self.isEditing {
			// Only allow changing location if we're in edit mode or saving a new location
			return
		}
		if gestureRecognizer.state == .began {
			let touchPoint = gestureRecognizer.location(in: mapView)
			let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
			viewModel.latitude = newCoordinates.latitude
			viewModel.longitude = newCoordinates.longitude
			updatePinnedLocation()
		}
	}

	// MARK: - MapKit helpers

	func tryUpdatingLocation() {
		if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
			mapView.showsUserLocation = true
			locationManager.startUpdatingLocation()
		} else {
			locationManager.requestWhenInUseAuthorization()
		}
	}

	func updatePinnedLocation() {
		let center = CLLocationCoordinate2D(latitude: viewModel.latitude, longitude: viewModel.longitude)
		let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

		self.mapView.setRegion(region, animated: true)

		locationManager.stopUpdatingLocation()

		var title = "Nice Place"
		if viewModel.name.trimmingCharacters(in: .whitespaces).characters.count > 0 {
			title = viewModel.name
		}
		let pin = MapPin(coordinate: center, title: title, subtitle: "")
		self.mapView.removeAnnotations(mapView.annotations)
		self.mapView.addAnnotation(pin)
	}

	// MARK: - Private helpers

	func savePlace() {
		viewModel.name = textField.text!
		savePlaceHandler(viewModel.name, viewModel.latitude, viewModel.longitude)
	}

	func mapItemFor(mapPin: MapPin) -> MKMapItem {
		let placemark = MKPlacemark(coordinate: mapPin.coordinate, addressDictionary: nil)

		let mapItem = MKMapItem(placemark: placemark)
		mapItem.name = mapPin.title

		return mapItem
	}

}

// MARK: - UITextFieldDelegate
extension PlaceViewController: UITextFieldDelegate {

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()

		// Return false to avoid further processing of the Return button
		return false
	}

}

// MARK: - CLLocationManagerDelegate
extension PlaceViewController: CLLocationManagerDelegate {

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let location = locations.last
		print("Found user location: \(location.debugDescription)")

		viewModel.latitude = location!.coordinate.latitude
		viewModel.longitude = location!.coordinate.longitude
		updatePinnedLocation()
	}
}

// MARK: - MKMapViewDelegate
extension PlaceViewController: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		guard let annotation = annotation as? MapPin else {
			return nil
		}
		let identifier = "pin"
		var view: MKPinAnnotationView
		if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
			view = dequeuedView
			view.annotation = annotation
		} else {
			view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
			view.canShowCallout = true
			view.calloutOffset = CGPoint(x: -5, y: 5)
			view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
		}
		return view
	}

	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		let location = view.annotation as! MapPin
		let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
		mapItemFor(mapPin: location).openInMaps(launchOptions: launchOptions)
	}
}
