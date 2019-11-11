//
//  Currency+CoreDataProperties.swift
//  
//
//  Created by Jakub on 21.05.2018.
//
//

import Foundation
import CoreData


extension Currency {

    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<Currency> {
        return NSFetchRequest<Currency>(entityName: "Currency")
    }

    @NSManaged public var name: String?
    @NSManaged public var rate: Double
    @NSManaged public var subCurrency: NSOrderedSet?

}

// MARK: Generated accessors for subCurrency
extension Currency {

    @objc(insertObject:inSubCurrencyAtIndex:)
    @NSManaged public func insertIntoSubCurrency(_ value: SubCurrency, at idx: Int)

    @objc(removeObjectFromSubCurrencyAtIndex:)
    @NSManaged public func removeFromSubCurrency(at idx: Int)

    @objc(insertSubCurrency:atIndexes:)
    @NSManaged public func insertIntoSubCurrency(_ values: [SubCurrency], at indexes: NSIndexSet)

    @objc(removeSubCurrencyAtIndexes:)
    @NSManaged public func removeFromSubCurrency(at indexes: NSIndexSet)

    @objc(replaceObjectInSubCurrencyAtIndex:withObject:)
    @NSManaged public func replaceSubCurrency(at idx: Int, with value: SubCurrency)

    @objc(replaceSubCurrencyAtIndexes:withSubCurrency:)
    @NSManaged public func replaceSubCurrency(at indexes: NSIndexSet, with values: [SubCurrency])

    @objc(addSubCurrencyObject:)
    @NSManaged public func addToSubCurrency(_ value: SubCurrency)

    @objc(removeSubCurrencyObject:)
    @NSManaged public func removeFromSubCurrency(_ value: SubCurrency)

    @objc(addSubCurrency:)
    @NSManaged public func addToSubCurrency(_ values: NSOrderedSet)

    @objc(removeSubCurrency:)
    @NSManaged public func removeFromSubCurrency(_ values: NSOrderedSet)

}
