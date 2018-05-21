//
//  SubCurrency+CoreDataProperties.swift
//  
//
//  Created by Jakub on 16.05.2018.
//
//

import Foundation
import CoreData


extension SubCurrency {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubCurrency> {
        return NSFetchRequest<SubCurrency>(entityName: "SubCurrency")
    }

    @NSManaged public var name: String?
    @NSManaged public var rate: Double

}
