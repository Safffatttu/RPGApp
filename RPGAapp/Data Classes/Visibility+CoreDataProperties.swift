//
//  Visibility+CoreDataProperties.swift
//  RPGAapp
//
//  Created by Jakub on 01.07.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import CoreData


extension Visibility {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Visibility> {
        return NSFetchRequest<Visibility>(entityName: "Visibility")
    }

    @NSManaged public var name: String?
    @NSManaged public var id: String?
    @NSManaged public var current: Bool
    @NSManaged public var session: Session?

}
