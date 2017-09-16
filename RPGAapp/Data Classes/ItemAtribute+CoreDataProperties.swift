//
//  ItemAtribute+CoreDataProperties.swift
//  
//
//  Created by Jakub on 16.09.2017.
//
//

import Foundation
import CoreData


extension ItemAtribute {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemAtribute> {
        return NSFetchRequest<ItemAtribute>(entityName: "ItemAtribute")
    }

    @NSManaged public var name: String?
    @NSManaged public var priceMod: Double
    @NSManaged public var rarityMod: Double

}
