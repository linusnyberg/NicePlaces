//
//  Place+CoreDataClass.swift
//  NicePlaces
//
//  Created by Linus Nyberg on 2017-04-24.
//  Copyright © 2017 Linus Nyberg. All rights reserved.
//

import Foundation
import CoreData
import MapKit

public class Place: NSManagedObject, ManuallySortable {

}

extension Place: MKAnnotation {
	public var coordinate: CLLocationCoordinate2D {
		let latDegrees = CLLocationDegrees(latitude)
		let longDegrees = CLLocationDegrees(longitude)
		return CLLocationCoordinate2D(latitude: latDegrees, longitude: longDegrees)
	}
}
