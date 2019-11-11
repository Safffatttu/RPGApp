//
//  StorePurchases+CoreDataProperties.swift
//  
//
//  Created by Jakub on 21.05.2018.
//
//

import Foundation
import CoreData


extension StorePurchases {

    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<StorePurchases> {
        return NSFetchRequest<StorePurchases>(entityName: "StorePurchases")
    }

    @NSManaged public var maxRarity: Int16
    @NSManaged public var minRarity: Int16
    @NSManaged public var priceMod: Double
    @NSManaged public var category: Category?
    @NSManaged public var subCategory: SubCategory?

}
