//
//  SubCurrency+CoreDataProperties.swift
//  
//
//  Created by Jakub on 21.09.2017.
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
