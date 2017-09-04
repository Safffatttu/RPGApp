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
    @NSManaged public var items: NSSet?

}

// MARK: Generated accessors for items
extension Package {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: Item)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: Item)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}
