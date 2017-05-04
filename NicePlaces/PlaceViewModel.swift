//
//  PlaceViewModel.swift
//  NicePlaces
//
//  Created by Linus Nyberg on 2017-04-25.
//  Copyright © 2017 Linus Nyberg. All rights reserved.
//

import Foundation

/// View model for PlaceViewController
struct PlaceViewModel {

	var name: String = ""
	var latitude: Double = 0
	var longitude: Double = 0
	var geocoderName: String = ""

	init() {
	}

	init(place: Place) {
		self.name = place.name
		self.latitude = place.latitude
		self.longitude = place.longitude
		self.geocoderName = place.geocoderName
	}

	func copyDataToPlace(place: Place) {
		place.name = name
		place.latitude = latitude
		place.longitude = longitude
		place.geocoderName = geocoderName
	}
}
