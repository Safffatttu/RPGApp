//
//  ItemAtributeHandler+CoreDataProperties.swift
//  
//
//  Created by Jakub on 16.09.2017.
//
//

import Foundation
import CoreData


extension ItemAtributeHandler {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemAtributeHandler> {
        return NSFetchRequest<ItemAtributeHandler>(entityName: "ItemAtributeHandler")
    }

    @NSManaged public var itemAtributes: NSSet?

}

// MARK: Generated accessors for itemAtributes
extension ItemAtributeHandler {

    @objc(addItemAtributesObject:)
    @NSManaged public func addToItemAtributes(_ value: ItemAtribute)

    @objc(removeItemAtributesObject:)
    @NSManaged public func removeFromItemAtributes(_ value: ItemAtribute)

    @objc(addItemAtributes:)
    @NSManaged public func addToItemAtributes(_ values: NSSet)

    @objc(removeItemAtributes:)
    @NSManaged public func removeFromItemAtributes(_ values: NSSet)

}
