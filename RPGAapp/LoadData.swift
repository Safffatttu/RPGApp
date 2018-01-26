//
//  LoadData.swift
//  RPGAapp
//
//  Created by Jakub on 25.01.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import CoreData

public struct Load {
    static let context = CoreDataStack.managedObjectContext
    
    public static func items() -> [Item] {
        var items: [Item] = []
        let itemFetch: NSFetchRequest<Item> = Item.fetchRequest()
        
        itemFetch.sortDescriptors = [.sortItemByName]
        
        do{
            items = try context.fetch(itemFetch)
        }
        catch{
            print("error fetching")
        }
        
        return items
    }
    
    public static func item(with ID: String) -> Item? {
        var item: Item?
        let itemFetch: NSFetchRequest<Item> = Item.fetchRequest()
        
        itemFetch.predicate = NSPredicate(format: "id == %@", ID)
        
        do{
            item = try context.fetch(itemFetch).first
        }
        catch{
            print("error fetching")
        }
        
        return item
    }
    
    public static func subCategories() -> [SubCategory] {
        var subCategories: [SubCategory] = []
        let subCategoryFetch: NSFetchRequest<SubCategory> = SubCategory.fetchRequest()
        subCategoryFetch.sortDescriptors = [.sortSubCategoryByCategory,.sortSubCategoryByName]
        subCategoryFetch.predicate = NSPredicate(format: "temp == %@", "NO")
        
        do{
            subCategories = try context.fetch(subCategoryFetch)
        }
        catch{
            print("error fetching")
        }
        
        return subCategories
    }
    
    public static func subCategoriesForCatalog() -> [(SubCategory,[Item])] {
        let subCats: [SubCategory] = subCategories()
        
        var subCategoriesToReturn: [(SubCategory,[Item])] = []
        
        for sub in subCats{
            let subCategory = (sub,sub.items?.sortedArray(using: [.sortItemByName]) as! [Item])
            subCategoriesToReturn.append(subCategory)
        }
        return subCategoriesToReturn
    }
    
    public static func categories() -> [Category] {
        var categories: [Category] = []
        let categoryFetch: NSFetchRequest<Category> = Category.fetchRequest()
        
        categoryFetch.sortDescriptors = [.sortCategoryByName]
        do{
            categories = try context.fetch(categoryFetch) as [Category]
        }
        catch{
            print("error fetching")
        }
        return categories
    }
 
    public static func sessions() -> [Session]{
        var sessions: [Session] = []
        let sessionFetch: NSFetchRequest<Session> = Session.fetchRequest()
        
        sessionFetch.sortDescriptors = [.sortSessionByName]
        
        do {
            sessions = try context.fetch(sessionFetch)
        }
        catch{
            print(error)
        }
        return sessions
    }
    
    public static func packages(fromCurrentSession: Bool = true) -> [Package]{
        var packages: [Package] = []
        if fromCurrentSession{
            let session = getCurrentSession()
            packages = session.packages?.sortedArray(using: [.sortPackageByName,.sortPackageById]) as! [Package]
        }else{
            let packagesFetch: NSFetchRequest<Package> = Package.fetchRequest()
            
            packagesFetch.sortDescriptors = [.sortPackageById]
            
            do{
                packages = try context.fetch(packagesFetch)
            }
            catch{
                print("error")
            }
        }
        
        return packages
    }
    
    public static func packages(with ID: String) -> Package?{
        var package: Package?

        let packageFetch: NSFetchRequest<Package> = Package.fetchRequest()
        
        packageFetch.predicate = NSPredicate(format: "id == %@", ID)
        
        do{
            package = try context.fetch(packageFetch).first
        }
        catch{
            print("error")
        }
        
        return package
    }
    
    public static func drawSettings() -> [DrawSetting]{
        var drawSettings: [DrawSetting] = []
        let drawSettingsFetch: NSFetchRequest<DrawSetting> = DrawSetting.fetchRequest()
        
        drawSettingsFetch.sortDescriptors = [NSSortDescriptor(key: #keyPath(DrawSetting.name), ascending: true)]
        
        do{
            drawSettings = try context.fetch(drawSettingsFetch) as [DrawSetting]
        }
        catch{
            print("error")
        }
        
        return drawSettings
    }
    
    public static func characters(fromCurrentSession: Bool = true) -> [Character]{
        var characters: [Character] = []
        
        if fromCurrentSession {
            let currentSession = getCurrentSession()
            characters = currentSession.characters?.sortedArray(using: [.sortCharacterById]) as! [Character]
        }else{
            let charactersFetch: NSFetchRequest<Character> = Character.fetchRequest()
            
            charactersFetch.sortDescriptors = [.sortCharacterById]
            
            do{
                characters = try context.fetch(charactersFetch)
            }
            catch{
                print("error")
            }
        }
        
        return characters
    }
    
    public static func character(with ID: String) -> Character?{
        var character: Character?
        
        let characterFetch: NSFetchRequest<Character> = Character.fetchRequest()
        
        characterFetch.predicate = NSPredicate(format: "id == %@", ID)
        
        do{
            character = try context.fetch(characterFetch).first
        }
        catch{
            print("error")
        }
        
        return character
    }
    
}



