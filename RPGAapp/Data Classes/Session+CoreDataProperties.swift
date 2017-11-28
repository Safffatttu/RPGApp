//
//  Session+CoreDataProperties.swift
//  
//
//  Created by Jakub on 23.11.2017.
//
//

import Foundation
import CoreData


extension Session {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Session> {
        return NSFetchRequest<Session>(entityName: "Session")
    }

    @NSManaged public var name: String?
    @NSManaged public var gameMaster: String?
    @NSManaged public var gameMasterName: String?
    @NSManaged public var current: Bool
    @NSManaged public var characters: NSSet?
    @NSManaged public var packages: NSSet?

}

// MARK: Generated accessors for characters
extension Session {

    @objc(addCharactersObject:)
    @NSManaged public func addToCharacters(_ value: Character)

    @objc(removeCharactersObject:)
    @NSManaged public func removeFromCharacters(_ value: Character)

    @objc(addCharacters:)
    @NSManaged public func addToCharacters(_ values: NSSet)

    @objc(removeCharacters:)
    @NSManaged public func removeFromCharacters(_ values: NSSet)

}

// MARK: Generated accessors for packages
extension Session {

    @objc(addPackagesObject:)
    @NSManaged public func addToPackages(_ value: Package)

    @objc(removePackagesObject:)
    @NSManaged public func removeFromPackages(_ value: Package)

    @objc(addPackages:)
    @NSManaged public func addToPackages(_ values: NSSet)

    @objc(removePackages:)
    @NSManaged public func removeFromPackages(_ values: NSSet)

}
