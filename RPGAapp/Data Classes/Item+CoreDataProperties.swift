//
//  Item+CoreDataProperties.swift
//  
//
//  Created by Jakub on 20.08.2017.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var category: String?
    @NSManaged public var item_description: String?
    @NSManaged public var measure: String?
    @NSManaged public var name: String?
    @NSManaged public var price: Double
    @NSManaged public var quantity: Int16
    @NSManaged public var rarity: Int16
    @NSManaged public var subCategory: String?

}
