//
//  Package+CoreDataProperties.swift
//  
//
//  Created by Jakub on 01.09.2017.
//
//

import Foundation
import CoreData


extension Package {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Package> {
        return NSFetchRequest<Package>(entityName: "Package")
    }

    @NSManaged public var name: String?
    @NSManaged public var relationship: NSSet?

}

// MARK: Generated accessors for relationship
extension Package {

    @objc(addRelationshipObject:)
    @NSManaged public func addToRelationship(_ value: Item)

    @objc(removeRelationshipObject:)
    @NSManaged public func removeFromRelationship(_ value: Item)

    @objc(addRelationship:)
    @NSManaged public func addToRelationship(_ values: NSSet)

    @objc(removeRelationship:)
    @NSManaged public func removeFromRelationship(_ values: NSSet)

}
