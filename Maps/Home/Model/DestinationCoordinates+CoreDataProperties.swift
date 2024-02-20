//
//  DestinationCoordinates+CoreDataProperties.swift
//  Maps
//
//  Created by Inderpreet Singh on 21/02/24.
//
//

import Foundation
import CoreData


extension DestinationCoordinates {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DestinationCoordinates> {
        return NSFetchRequest<DestinationCoordinates>(entityName: "DestinationCoordinates")
    }

    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?
    @NSManaged public var from: NSSet?

}

// MARK: Generated accessors for from
extension DestinationCoordinates {

    @objc(addFromObject:)
    @NSManaged public func addToFrom(_ value: FromCoordinates)

    @objc(removeFromObject:)
    @NSManaged public func removeFromFrom(_ value: FromCoordinates)

    @objc(addFrom:)
    @NSManaged public func addToFrom(_ values: NSSet)

    @objc(removeFrom:)
    @NSManaged public func removeFromFrom(_ values: NSSet)

}

extension DestinationCoordinates : Identifiable {

}
