//
//  FromCoordinates+CoreDataProperties.swift
//  Maps
//
//  Created by Inderpreet Singh on 21/02/24.
//
//

import Foundation
import CoreData


extension FromCoordinates {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FromCoordinates> {
        return NSFetchRequest<FromCoordinates>(entityName: "FromCoordinates")
    }

    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?
    @NSManaged public var destination: NSSet?

}

// MARK: Generated accessors for destination
extension FromCoordinates {

    @objc(addDestinationObject:)
    @NSManaged public func addToDestination(_ value: DestinationCoordinates)

    @objc(removeDestinationObject:)
    @NSManaged public func removeFromDestination(_ value: DestinationCoordinates)

    @objc(addDestination:)
    @NSManaged public func addToDestination(_ values: NSSet)

    @objc(removeDestination:)
    @NSManaged public func removeFromDestination(_ values: NSSet)

}

extension FromCoordinates : Identifiable {

}
