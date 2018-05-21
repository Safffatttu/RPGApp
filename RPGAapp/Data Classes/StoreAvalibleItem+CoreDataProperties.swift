//
//  StoreAvalibleItem+CoreDataProperties.swift
//  
//
//  Created by Jakub on 21.05.2018.
//
//

import Foundation
import CoreData


extension StoreAvalibleItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoreAvalibleItem> {
        return NSFetchRequest<StoreAvalibleItem>(entityName: "StoreAvalibleItem")
    }

    @NSManaged public var priceMod: Double
    @NSManaged public var item: NSSet?

}

// MARK: Generated accessors for item
extension StoreAvalibleItem {

    @objc(addItemObject:)
    @NSManaged public func addToItem(_ value: ItemHandler)

    @objc(removeItemObject:)
    @NSManaged public func removeFromItem(_ value: ItemHandler)

    @objc(addItem:)
    @NSManaged public func addToItem(_ values: NSSet)

    @objc(removeItem:)
    @NSManaged public func removeFromItem(_ values: NSSet)

}
