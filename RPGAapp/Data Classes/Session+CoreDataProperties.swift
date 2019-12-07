//
//  Session+CoreDataProperties.swift
//  
//
//  Created by Jakub on 16.05.2018.
//
//

import Foundation
import CoreData
import UIKit


extension Session {

    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<Session> {
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
    @NSManaged public var notes: NSSet?

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

// MARK: Generated accessors for notes
extension Session {

    @objc(addNotesObject:)
    @NSManaged public func addToNotes(_ value: Note)

    @objc(removeNotesObject:)
    @NSManaged public func removeFromNotes(_ value: Note)

    @objc(addNotes:)
    @NSManaged public func addToNotes(_ values: NSSet)

    @objc(removeNotes:)
    @NSManaged public func removeFromNotes(_ values: NSSet)

}
extension Session {
    
    @discardableResult
    static func create() -> Session {
        let context = CoreDataStack.managedObjectContext
        let session = NSEntityDescription.insertNewObject(forEntityName: String(describing: Session.self), into: context) as! Session
        session.name = NSLocalizedString("Session", comment: "")
        session.gameMaster = UIDevice.current.name
        
        session.id = String(strHash(session.name! + session.gameMaster! + String(describing: Date()) + String(myRand(100000))))

        let newMap = NSEntityDescription.insertNewObject(forEntityName: String(describing: Map.self), into: context) as! Map
        newMap.id = String(strHash(session.id!)) + String(describing: Date())
        newMap.current = true

        session.addToMaps(newMap)

        let PLN = Load.currencies().first { $0.name == "PLN" }
        session.currency = PLN

        var devices = PackageService.pack.session.connectedPeers.map { $0.displayName }
        devices.append(UIDevice.current.name)
        session.devices = NSSet(array: devices)
        
        Load.sessions().forEach { $0.current = false }
        session.current = true
        
        CoreDataStack.saveContext()

        NotificationCenter.default.post(name: .reloadTeam, object: nil)
        NotificationCenter.default.post(name: .currencyChanged, object: nil)

        let action = SessionReceived(session: session, setCurrent: session.current)
        PackageService.pack.send(action: action)
        
        return session
    }
}
