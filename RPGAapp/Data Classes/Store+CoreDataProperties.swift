//
//  Store+CoreDataProperties.swift
//  
//
//  Created by Jakub on 21.05.2018.
//
//

import Foundation
import CoreData


extension Store {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Store> {
        return NSFetchRequest<Store>(entityName: "Store")
    }

    @NSManaged public var budget: Double
    @NSManaged public var name: String?
    @NSManaged public var size: Int16
    @NSManaged public var avalibleItems: NSSet?
    @NSManaged public var buys: StorePurchases?

}

// MARK: Generated accessors for avalibleItems
extension Store {

    @objc(addAvalibleItemsObject:)
    @NSManaged public func addToAvalibleItems(_ value: StoreAvalibleItem)

    @objc(removeAvalibleItemsObject:)
    @NSManaged public func removeFromAvalibleItems(_ value: StoreAvalibleItem)

    @objc(addAvalibleItems:)
    @NSManaged public func addToAvalibleItems(_ values: NSSet)

    @objc(removeAvalibleItems:)
    @NSManaged public func removeFromAvalibleItems(_ values: NSSet)

}
