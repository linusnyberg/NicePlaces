//
//  Place+CoreDataProperties.swift
//  NicePlaces
//
//  Created by Linus Nyberg on 2017-04-24.
//  Copyright © 2017 Linus Nyberg. All rights reserved.
//

import Foundation
import CoreData


extension Place {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Place> {
        return NSFetchRequest<Place>(entityName: "Place")
    }

    @NSManaged public var name: String
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
	@NSManaged public var order: Double

}
