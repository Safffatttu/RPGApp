//
//  Visibility+CoreDataProperties.swift
//  RPGAapp
//
//  Created by Jakub on 01.07.2018.
//

import Foundation
import CoreData


extension Visibility {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Visibility> {
        return NSFetchRequest<Visibility>(entityName: "Visibility")
    }

    @NSManaged public var current: Bool
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var session: Session?
    @NSManaged public var characters: NSSet?
    @NSManaged public var packages: Package?

}

// MARK: Generated accessors for characters
extension Visibility {

    @objc(addCharactersObject:)
    @NSManaged public func addToCharacters(_ value: Character)

    @objc(removeCharactersObject:)
    @NSManaged public func removeFromCharacters(_ value: Character)

    @objc(addCharacters:)
    @NSManaged public func addToCharacters(_ values: NSSet)

    @objc(removeCharacters:)
    @NSManaged public func removeFromCharacters(_ values: NSSet)

}
