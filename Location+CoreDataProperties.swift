//
//  Location+CoreDataProperties.swift
//  Maps
//
//  Created by Inderpreet Singh on 21/02/24.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var fromCoordinates: Double
    @NSManaged public var name: String?
    @NSManaged public var path: Data?
    @NSManaged public var toCoordinates: Double

}

extension Location : Identifiable {

}
