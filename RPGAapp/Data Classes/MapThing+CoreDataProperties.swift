//
//  MapThing+CoreDataProperties.swift
//  
//
//  Created by Jakub on 16.05.2018.
//
//

import Foundation
import CoreData


extension MapThing {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MapThing> {
        return NSFetchRequest<MapThing>(entityName: "MapThing")
    }

    @NSManaged public var id: String?
    @NSManaged public var x: Double
    @NSManaged public var y: Double
    @NSManaged public var texture: NSData?
    @NSManaged public var map: Map?
    @NSManaged public var character: Character?

}
