//
//  DrawSubSetting+CoreDataProperties.swift
//  
//
//  Created by Jakub on 03.09.2017.
//
//

import Foundation
import CoreData


extension DrawSubSetting {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DrawSubSetting> {
        return NSFetchRequest<DrawSubSetting>(entityName: "DrawSubSetting")
    }

    @NSManaged public var name: String?
    @NSManaged public var itemsToDraw: Int64
    @NSManaged public var category: Category?
    @NSManaged public var subCategory: SubCategory?

}
