//
//  Package+CoreDataProperties.swift
//  
//
//  Created by Jakub on 16.09.2017.
//
//

import Foundation
import CoreData


extension Package {

    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<Package> {
        return NSFetchRequest<Package>(entityName: "Package")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var items: NSSet?
    @NSManaged public var session: Session?
    @NSManaged public var visibility: Visibility?

}

// MARK: Generated accessors for items
extension Package {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: ItemHandler)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: ItemHandler)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}

extension Package {
    func add(_ item: Item, count: Int64? = nil) {
        let context = CoreDataStack.managedObjectContext
        
        var itemHandler = self.items?.first(where: { ($0 as! ItemHandler).item == item }) as? ItemHandler
        
        guard let itemId = item.id else { return }
        var itemCount: Int64
        
        if itemHandler == nil {
            itemHandler = NSEntityDescription.insertNewObject(forEntityName: String(describing: ItemHandler.self), into: context) as? ItemHandler
            itemHandler!.item = item
            if count != nil {
                itemHandler!.count = count!
            }
            self.addToItems(itemHandler!)
        }
        
        if let count = count {
            itemHandler?.count += count
            itemCount = count
        } else {
            itemHandler?.count += 1
            itemCount = 1
        }
        
        NotificationCenter.default.post(name: .addedItemToPackage, object: nil)
        
        let action = ItemPackageAdded(package: self, itemsId: [itemId], itemsCount: [itemCount])
        
        PackageService.pack.send(action: action)
    }
}
