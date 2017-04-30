//
//  ManuallySortable.swift
//  NicePlaces
//
//  Created by Linus Nyberg on 2017-04-30.
//  Copyright © 2017 Linus Nyberg. All rights reserved.
//

import Foundation

/// Protocol for objects that can be manually reordered. See `ManualSorter`.
protocol ManuallySortable {
	var order: Double { get set }
}
