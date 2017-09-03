//
//  Category+CoreDataProperties.swift
//  
//
//  Created by Jakub on 01.09.2017.
//
//

import Foundation
import CoreData


extension Category {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }
    
    @NSManaged public var name: String?
    @NSManaged public var items: NSSet?
    @NSManaged public var subCateogories: NSSet?
    
}

// MARK: Generated accessors for items
extension Category {
    
    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: Item)
    
    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: Item)
    
    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)
    
    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)
    
}

// MARK: Generated accessors for subCateogories
extension Category {
    
    @objc(addSubCateogoriesObject:)
    @NSManaged public func addToSubCateogories(_ value: SubCategory)
    
    @objc(removeSubCateogoriesObject:)
    @NSManaged public func removeFromSubCateogories(_ value: SubCategory)
    
    @objc(addSubCateogories:)
    @NSManaged public func addToSubCateogories(_ values: NSSet)
    
    @objc(removeSubCateogories:)
    @NSManaged public func removeFromSubCateogories(_ values: NSSet)
    
}

