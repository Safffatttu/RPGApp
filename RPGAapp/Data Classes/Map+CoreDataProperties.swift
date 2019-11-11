//
//  Map+CoreDataProperties.swift
//  
//
//  Created by Jakub on 16.05.2018.
//
//

import Foundation
import CoreData


extension Map {

    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<Map> {
        return NSFetchRequest<Map>(entityName: "Map")
    }

    @NSManaged public var current: Bool
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var x: Double
    @NSManaged public var y: Double
    @NSManaged public var background: Texture?
    @NSManaged public var entities: NSSet?
    @NSManaged public var session: Session?

}

// MARK: Generated accessors for entities
extension Map {

    @objc(addEntitiesObject:)
    @NSManaged public func addToEntities(_ value: MapEntity)

    @objc(removeEntitiesObject:)
    @NSManaged public func removeFromEntities(_ value: MapEntity)

    @objc(addEntities:)
    @NSManaged public func addToEntities(_ values: NSSet)

    @objc(removeEntities:)
    @NSManaged public func removeFromEntities(_ values: NSSet)

}
