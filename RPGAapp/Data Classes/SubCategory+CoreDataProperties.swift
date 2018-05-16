//
//  SubCategory+CoreDataProperties.swift
//  
//
//  Created by Jakub on 01.09.2017.
//
//

import Foundation
import CoreData


extension SubCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubCategory> {
        return NSFetchRequest<SubCategory>(entityName: "SubCategory")
    }

    @NSManaged public var name: String?
    @NSManaged public var temp: Bool
    @NSManaged public var category: Category?
    @NSManaged public var items: NSSet?
    
}

// MARK: Generated accessors for items
extension SubCategory {
    
    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: Item)
    
    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: Item)
    
    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)
    
    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)
    
}

