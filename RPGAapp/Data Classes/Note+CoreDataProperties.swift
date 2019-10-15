//
//  Note+CoreDataProperties.swift
//  
//
//  Created by Jakub on 04.10.2018.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var id: String?
    @NSManaged public var text: String?
    @NSManaged public var session: Session?
    @NSManaged public var visibility: Visibility?

}
