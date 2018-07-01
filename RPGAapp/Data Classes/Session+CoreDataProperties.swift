//
//  Session+CoreDataProperties.swift
//  
//
//  Created by Jakub on 16.05.2018.
//
//

import Foundation
import CoreData


extension Session {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Session> {
        return NSFetchRequest<Session>(entityName: "Session")
    }

    @NSManaged public var current: Bool
    @NSManaged public var devices: NSObject?
    @NSManaged public var gameMaster: String?
    @NSManaged public var gameMasterName: String?
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var characters: NSSet?
    @NSManaged public var currency: Currency?
    @NSManaged public var maps: NSSet?
    @NSManaged public var packages: NSSet?
    @NSManaged public var visibility: NSSet?

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

// MARK: Generated accessors for maps
extension Session {

    @objc(addMapsObject:)
    @NSManaged public func addToMaps(_ value: Map)

    @objc(removeMapsObject:)
    @NSManaged public func removeFromMaps(_ value: Map)

    @objc(addMaps:)
    @NSManaged public func addToMaps(_ values: NSSet)

    @objc(removeMaps:)
    @NSManaged public func removeFromMaps(_ values: NSSet)

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

// MARK: Generated accessors for visibility
extension Session {

    @objc(addVisibilityObject:)
    @NSManaged public func addToVisibility(_ value: Visibility)

    @objc(removeVisibilityObject:)
    @NSManaged public func removeFromVisibility(_ value: Visibility)

    @objc(addVisibility:)
    @NSManaged public func addToVisibility(_ values: NSSet)

    @objc(removeVisibility:)
    @NSManaged public func removeFromVisibility(_ values: NSSet)

}
