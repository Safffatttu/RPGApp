//
//  ItemAtribute+CoreDataProperties.swift
//  
//
//  Created by Jakub on 16.11.2017.
//
//

import Foundation
import CoreData


extension ItemAtribute {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemAtribute> {
        return NSFetchRequest<ItemAtribute>(entityName: "ItemAtribute")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var priceMod: Double
    @NSManaged public var rarityMod: Double
    @NSManaged public var excludingAtributes: NSSet?
    @NSManaged public var item: Item?
    @NSManaged public var requiredAtributes: NSSet?

}

// MARK: Generated accessors for excludingAtributes
extension ItemAtribute {

    @objc(addExcludingAtributesObject:)
    @NSManaged public func addToExcludingAtributes(_ value: ItemAtribute)

    @objc(removeExcludingAtributesObject:)
    @NSManaged public func removeFromExcludingAtributes(_ value: ItemAtribute)

    @objc(addExcludingAtributes:)
    @NSManaged public func addToExcludingAtributes(_ values: NSSet)

    @objc(removeExcludingAtributes:)
    @NSManaged public func removeFromExcludingAtributes(_ values: NSSet)

}

// MARK: Generated accessors for requiredAtributes
extension ItemAtribute {

    @objc(addRequiredAtributesObject:)
    @NSManaged public func addToRequiredAtributes(_ value: ItemAtribute)

    @objc(removeRequiredAtributesObject:)
    @NSManaged public func removeFromRequiredAtributes(_ value: ItemAtribute)

    @objc(addRequiredAtributes:)
    @NSManaged public func addToRequiredAtributes(_ values: NSSet)

    @objc(removeRequiredAtributes:)
    @NSManaged public func removeFromRequiredAtributes(_ values: NSSet)

}
