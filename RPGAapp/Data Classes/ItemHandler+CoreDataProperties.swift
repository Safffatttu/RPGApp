//
//  ItemHandler+CoreDataProperties.swift
//  
//
//  Created by Jakub on 16.09.2017.
//
//

import Foundation
import CoreData


extension ItemHandler {

    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<ItemHandler> {
        return NSFetchRequest<ItemHandler>(entityName: "ItemHandler")
    }

    @NSManaged public var count: Int64
    @NSManaged public var item: Item?
    @NSManaged public var itemAtributesHandler: NSOrderedSet?
    @NSManaged public var owner: Character?

}

// MARK: Generated accessors for itemAtributesHandler
extension ItemHandler {

    @objc(insertObject:inItemAtributesHandlerAtIndex:)
    @NSManaged public func insertIntoItemAtributesHandler(_ value: ItemAtributeHandler, at idx: Int)

    @objc(removeObjectFromItemAtributesHandlerAtIndex:)
    @NSManaged public func removeFromItemAtributesHandler(at idx: Int)

    @objc(insertItemAtributesHandler:atIndexes:)
    @NSManaged public func insertIntoItemAtributesHandler(_ values: [ItemAtributeHandler], at indexes: NSIndexSet)

    @objc(removeItemAtributesHandlerAtIndexes:)
    @NSManaged public func removeFromItemAtributesHandler(at indexes: NSIndexSet)

    @objc(replaceObjectInItemAtributesHandlerAtIndex:withObject:)
    @NSManaged public func replaceItemAtributesHandler(at idx: Int, with value: ItemAtributeHandler)

    @objc(replaceItemAtributesHandlerAtIndexes:withItemAtributesHandler:)
    @NSManaged public func replaceItemAtributesHandler(at indexes: NSIndexSet, with values: [ItemAtributeHandler])

    @objc(addItemAtributesHandlerObject:)
    @NSManaged public func addToItemAtributesHandler(_ value: ItemAtributeHandler)

    @objc(removeItemAtributesHandlerObject:)
    @NSManaged public func removeFromItemAtributesHandler(_ value: ItemAtributeHandler)

    @objc(addItemAtributesHandler:)
    @NSManaged public func addToItemAtributesHandler(_ values: NSOrderedSet)

    @objc(removeItemAtributesHandler:)
    @NSManaged public func removeFromItemAtributesHandler(_ values: NSOrderedSet)

}
