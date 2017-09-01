//
//  Character+CoreDataProperties.swift
//  
//
//  Created by Jakub on 20.08.2017.
//
//

import Foundation
import CoreData


extension Character {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Character> {
        return NSFetchRequest<Character>(entityName: "Character")
    }

    @NSManaged public var health: Double?
    @NSManaged public var name: String
    @NSManaged public var race: String?
    @NSManaged public var equipment: NSSet?

}

// MARK: Generated accessors for equipment
extension Character {

    @objc(addEquipmentObject:)
    @NSManaged public func addToEquipment(_ value: Item)

    @objc(removeEquipmentObject:)
    @NSManaged public func removeFromEquipment(_ value: Item)

    @objc(addEquipment:)
    @NSManaged public func addToEquipment(_ values: NSSet)

    @objc(removeEquipment:)
    @NSManaged public func removeFromEquipment(_ values: NSSet)

}
