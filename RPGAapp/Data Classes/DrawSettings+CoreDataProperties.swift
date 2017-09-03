//
//  DrawSettings+CoreDataProperties.swift
//  
//
//  Created by Jakub on 03.09.2017.
//
//

import Foundation
import CoreData


extension DrawSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DrawSettings> {
        return NSFetchRequest<DrawSettings>(entityName: "DrawSettings")
    }

    @NSManaged public var name: String?
    @NSManaged public var subSettings: NSSet?

}

// MARK: Generated accessors for subSettings
extension DrawSettings {

    @objc(addSubSettingsObject:)
    @NSManaged public func addToSubSettings(_ value: DrawSubSetting)

    @objc(removeSubSettingsObject:)
    @NSManaged public func removeFromSubSettings(_ value: DrawSubSetting)

    @objc(addSubSettings:)
    @NSManaged public func addToSubSettings(_ values: NSSet)

    @objc(removeSubSettings:)
    @NSManaged public func removeFromSubSettings(_ values: NSSet)

}
