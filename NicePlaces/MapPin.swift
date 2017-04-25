//
//  MapPin.swift
//  NicePlaces
//
//  Created by Linus Nyberg on 2017-04-22.
//  Copyright © 2017 Linus Nyberg. All rights reserved.
//

import Foundation
import MapKit

/// A simple MapKit annotation (pin) for a map view.
class MapPin: NSObject, MKAnnotation {
	var coordinate: CLLocationCoordinate2D
	var title: String?
	var subtitle: String?

	init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
		self.coordinate = coordinate
		self.title = title
		self.subtitle = subtitle
	}
}
