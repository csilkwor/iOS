//
//  Location.swift
//  TrailGuide
//
//  Created by Connor Silkworth on 12/7/15.
//  Copyright © 2015 csilkwor. All rights reserved.
//

import Foundation
import CoreData

class Location: NSManagedObject {

    @NSManaged var timestamp: NSDate
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var track: NSManagedObject

}
