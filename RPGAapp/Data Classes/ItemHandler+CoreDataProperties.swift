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

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemHandler> {
        return NSFetchRequest<ItemHandler>(entityName: "ItemHandler")
    }

    @NSManaged public var number: Int16
    @NSManaged public var item: NSOrderedSet?
    @NSManaged public var itemAtributesHandler: NSOrderedSet?

}

// MARK: Generated accessors for item
extension ItemHandler {

    @objc(insertObject:inItemAtIndex:)
    @NSManaged public func insertIntoItem(_ value: Item, at idx: Int)

    @objc(removeObjectFromItemAtIndex:)
    @NSManaged public func removeFromItem(at idx: Int)

    @objc(insertItem:atIndexes:)
    @NSManaged public func insertIntoItem(_ values: [Item], at indexes: NSIndexSet)

    @objc(removeItemAtIndexes:)
    @NSManaged public func removeFromItem(at indexes: NSIndexSet)

    @objc(replaceObjectInItemAtIndex:withObject:)
    @NSManaged public func replaceItem(at idx: Int, with value: Item)

    @objc(replaceItemAtIndexes:withItem:)
    @NSManaged public func replaceItem(at indexes: NSIndexSet, with values: [Item])

    @objc(addItemObject:)
    @NSManaged public func addToItem(_ value: Item)

    @objc(removeItemObject:)
    @NSManaged public func removeFromItem(_ value: Item)

    @objc(addItem:)
    @NSManaged public func addToItem(_ values: NSOrderedSet)

    @objc(removeItem:)
    @NSManaged public func removeFromItem(_ values: NSOrderedSet)

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
