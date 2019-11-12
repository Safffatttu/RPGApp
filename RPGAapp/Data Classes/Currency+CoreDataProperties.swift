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

extension Currency {
    
    @discardableResult
    static func create(name: String, rate: Double, subList: [(String, Int16)]) -> Currency {
        let context = CoreDataStack.managedObjectContext
        let currency = NSEntityDescription.insertNewObject(forEntityName: String(describing: Currency.self), into: context) as! Currency
        
        currency.name = name
        currency.rate = rate
        
        
        for sub in subList {
            let subCurrency = NSEntityDescription.insertNewObject(forEntityName: String(describing: SubCurrency.self), into: context) as! SubCurrency
            
            subCurrency.name = sub.0
            subCurrency.rate = sub.1
            
            currency.addToSubCurrency(subCurrency)
        }
        
        CoreDataStack.saveContext()
        
        return currency
    }
    
    static func createBasicCurrency() {
        Currency.create(name: "PLN", rate: 1, subList: [("Zł", 1), ("Gr", 100)])
        Currency.create(name: "ZkSrM", rate: 1, subList: [("Zk", 1), ("Sr", 12), ("M", 12)])
        CoreDataStack.saveContext()
    }
}
