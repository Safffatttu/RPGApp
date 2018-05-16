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

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Map> {
        return NSFetchRequest<Map>(entityName: "Map")
    }

    @NSManaged public var id: String?
    @NSManaged public var background: NSData?
    @NSManaged public var name: String?
    @NSManaged public var x: Double
    @NSManaged public var y: Double
    @NSManaged public var things: MapThing?
    @NSManaged public var session: Session?

}
