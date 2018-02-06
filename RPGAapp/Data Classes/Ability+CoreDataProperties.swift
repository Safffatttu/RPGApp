//
//  Ability+CoreDataProperties.swift
//  
//
//  Created by Jakub on 06.02.2018.
//
//

import Foundation
import CoreData


extension Ability {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ability> {
        return NSFetchRequest<Ability>(entityName: "Ability")
    }

    @NSManaged public var name: String
    @NSManaged public var value: Int16
    @NSManaged public var id: String
    @NSManaged public var character: Character

}
