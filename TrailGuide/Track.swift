//
//  Track.swift
//  TrailGuide
//
//  Created by Connor Silkworth on 12/7/15.
//  Copyright © 2015 csilkwor. All rights reserved.
//

import Foundation
import CoreData

class Track: NSManagedObject {

    @NSManaged var duration: NSNumber
    @NSManaged var distance: NSNumber
    @NSManaged var timestamp: NSDate
    @NSManaged var locations: NSOrderedSet

}
