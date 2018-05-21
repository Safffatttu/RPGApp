//
//  Item+CoreDataProperties.swift
//  
//
//  Created by Jakub on 16.09.2017.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var baseDescription: String?
    @NSManaged public var id: String?
    @NSManaged public var item_description: String?
    @NSManaged public var measure: String?
    @NSManaged public var name: String?
    @NSManaged public var price: Double
    @NSManaged public var propability: Int64
    @NSManaged public var quantity: Int16
    @NSManaged public var rarity: Int16
    @NSManaged public var category: Category?
    @NSManaged public var handelers: NSSet?
    @NSManaged public var itemAtribute: NSSet?
    @NSManaged public var subCategory: SubCategory?

}

// MARK: Generated accessors for handelers
extension Item {

    @objc(addHandelersObject:)
    @NSManaged public func addToHandelers(_ value: ItemHandler)

    @objc(removeHandelersObject:)
    @NSManaged public func removeFromHandelers(_ value: ItemHandler)

    @objc(addHandelers:)
    @NSManaged public func addToHandelers(_ values: NSSet)

    @objc(removeHandelers:)
    @NSManaged public func removeFromHandelers(_ values: NSSet)

}

// MARK: Generated accessors for itemAtribute
extension Item {

    @objc(addItemAtributeObject:)
    @NSManaged public func addToItemAtribute(_ value: ItemAtribute)

    @objc(removeItemAtributeObject:)
    @NSManaged public func removeFromItemAtribute(_ value: ItemAtribute)

    @objc(addItemAtribute:)
    @NSManaged public func addToItemAtribute(_ values: NSSet)

    @objc(removeItemAtribute:)
    @NSManaged public func removeFromItemAtribute(_ values: NSSet)

}
