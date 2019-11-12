//
//  Visibility+CoreDataProperties.swift
//  RPGAapp
//
//  Created by Jakub on 01.07.2018.
//

import Foundation
import CoreData


extension Visibility {

    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<Visibility> {
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

extension Visibility {
    
    static func createVisibility() -> Visibility{
        let context = CoreDataStack.managedObjectContext
        let newVisibility = NSEntityDescription.insertNewObject(forEntityName: String(describing: Visibility.self), into: context) as! Visibility
        
        newVisibility.name = NameGenerator.createVisibilityData().0
        newVisibility.current = true
        newVisibility.id = String(describing: Date()) + newVisibility.name! + String(myRand(10000))
        newVisibility.session = Load.currentSession()
        
        let currentVisibilities = Load.visibilities().filter({ $0.current })
        
        for visib in currentVisibilities {
            visib.current = false
        }
        
        newVisibility.current = true
        
        CoreDataStack.saveContext()
        
        NotificationCenter.default.post(name: .reloadTeam, object: nil)
        
        let action = VisibilityCreated(visibility: newVisibility)
        PackageService.pack.send(action: action)
        
        return newVisibility
    }
}

