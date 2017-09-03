//
//  Character+CoreDataProperties.swift
//  
//
//  Created by Jakub on 01.09.2017.
//
//

import Foundation
import CoreData


extension Character {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Character> {
        return NSFetchRequest<Character>(entityName: "Character")
    }

    @NSManaged public var health: Double
    @NSManaged public var name: String?
    @NSManaged public var race: String?
    @NSManaged public var equipment: NSOrderedSet?

    let className = NSStringFromClass(Category.self)
}

// MARK: Generated accessors for equipment
extension Character {

    @objc(insertObject:inEquipmentAtIndex:)
    @NSManaged public func insertIntoEquipment(_ value: Item, at idx: Int)

    @objc(removeObjectFromEquipmentAtIndex:)
    @NSManaged public func removeFromEquipment(at idx: Int)

    @objc(insertEquipment:atIndexes:)
    @NSManaged public func insertIntoEquipment(_ values: [Item], at indexes: NSIndexSet)

    @objc(removeEquipmentAtIndexes:)
    @NSManaged public func removeFromEquipment(at indexes: NSIndexSet)

    @objc(replaceObjectInEquipmentAtIndex:withObject:)
    @NSManaged public func replaceEquipment(at idx: Int, with value: Item)

    @objc(replaceEquipmentAtIndexes:withEquipment:)
    @NSManaged public func replaceEquipment(at indexes: NSIndexSet, with values: [Item])

    @objc(addEquipmentObject:)
    @NSManaged public func addToEquipment(_ value: Item)

    @objc(removeEquipmentObject:)
    @NSManaged public func removeFromEquipment(_ value: Item)

    @objc(addEquipment:)
    @NSManaged public func addToEquipment(_ values: NSOrderedSet)

    @objc(removeEquipment:)
    @NSManaged public func removeFromEquipment(_ values: NSOrderedSet)

}
