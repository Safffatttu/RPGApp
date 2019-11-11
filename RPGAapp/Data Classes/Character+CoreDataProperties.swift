//
//  Character+CoreDataProperties.swift
//  
//
//  Created by Jakub on 14.11.2017.
//
//

import Foundation
import CoreData


extension Character {

    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<Character> {
        return NSFetchRequest<Character>(entityName: "Character")
    }

    @NSManaged public var health: Int16
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var profession: String?
    @NSManaged public var race: String?
    @NSManaged public var money: Double
    @NSManaged public var abilities: NSSet?
    @NSManaged public var equipment: NSSet?
    @NSManaged public var mapRepresentation: MapEntity?
    @NSManaged public var session: Session?
    @NSManaged public var visibility: Visibility?

}

// MARK: Generated accessors for abilities
extension Character {

    @objc(addAbilitiesObject:)
    @NSManaged public func addToAbilities(_ value: Ability)

    @objc(removeAbilitiesObject:)
    @NSManaged public func removeFromAbilities(_ value: Ability)

    @objc(addAbilities:)
    @NSManaged public func addToAbilities(_ values: NSSet)

    @objc(removeAbilities:)
    @NSManaged public func removeFromAbilities(_ values: NSSet)

}

// MARK: Generated accessors for equipment
extension Character {

    @objc(addEquipmentObject:)
    @NSManaged public func addToEquipment(_ value: ItemHandler)

    @objc(removeEquipmentObject:)
    @NSManaged public func removeFromEquipment(_ value: ItemHandler)

    @objc(addEquipment:)
    @NSManaged public func addToEquipment(_ values: NSSet)

    @objc(removeEquipment:)
    @NSManaged public func removeFromEquipment(_ values: NSSet)

}
