//
//  Package+CoreDataProperties.swift
//  
//
//  Created by Jakub on 16.09.2017.
//
//

import Foundation
import CoreData


extension Package {

    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<Package> {
        return NSFetchRequest<Package>(entityName: "Package")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var items: NSSet?
    @NSManaged public var session: Session?
    @NSManaged public var visibility: Visibility?

}

// MARK: Generated accessors for items
extension Package {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: ItemHandler)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: ItemHandler)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}
