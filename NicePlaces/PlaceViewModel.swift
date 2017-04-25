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

	init() {
	}

	init(place: Place) {
		self.name = place.name
		self.latitude = place.latitude
		self.longitude = place.longitude
	}
}
