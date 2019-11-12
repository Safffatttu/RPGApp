//
//  MapEntity+CoreDataProperties.swift
//  
//
//  Created by Jakub on 16.05.2018.
//
//

import Foundation
import CoreData


extension MapEntity {

    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<MapEntity> {
        return NSFetchRequest<MapEntity>(entityName: "MapEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var x: Double
    @NSManaged public var y: Double
    @NSManaged public var character: Character?
    @NSManaged public var map: Map?
    @NSManaged public var texture: Texture?

}
