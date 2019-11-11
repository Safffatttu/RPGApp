//
//  Texture+CoreDataProperties.swift
//  
//
//  Created by Jakub on 25.06.2018.
//
//

import Foundation
import CoreData


extension Texture {

    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<Texture> {
        return NSFetchRequest<Texture>(entityName: "Texture")
    }

    @NSManaged public var data: NSData?
    @NSManaged public var mapEntity: MapEntity?
    @NSManaged public var map: Map?

}
