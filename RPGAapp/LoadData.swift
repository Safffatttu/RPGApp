//
//  LoadData.swift
//  RPGAapp
//
//  Created by Jakub on 25.01.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import CoreData
import UIKit

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
        
        do{
            subCategories = try context.fetch(subCategoryFetch).filter({!$0.temp})
        }
        catch{
            print("error fetching")
        }
        
        return subCategories
    }
	
	public static func subCategoriesForCataloge() -> [SubCategory] {
		let subCategories: [SubCategory] = categories().flatMap{
			$0.subCategories?.sortedArray(using: [.sortSubCategoryByName]) as! [SubCategory]
		}
		
		return subCategories
	}
	
    public static func itemsForCataloge() -> [(SubCategory,[Item])] {
		let subCats = subCategoriesForCataloge()
		
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
	
	public static func session(with Id: String) -> Session?{
		var sessions: [Session] = []
		let sessionFetch: NSFetchRequest<Session> = Session.fetchRequest()
		
		sessionFetch.sortDescriptors = [.sortSessionByName]
		
		do {
			sessions = try context.fetch(sessionFetch)
		}
		catch{
			print(error)
		}
		
		return sessions.first(where: {$0.id == Id})
	}
	
	public static func currentSession() -> Session{
		
		let sessions = Load.sessions().filter{$0.current}
		
		if sessions.count == 0{
			let session = NSEntityDescription.insertNewObject(forEntityName: String(describing: Session.self), into: context) as! Session
			session.name = "Sesja"
			session.gameMaster = UIDevice.current.name
			session.current = true
			session.id = String(strHash(session.name! + session.gameMaster! + String(describing: Date())))
			
			let newMap = NSEntityDescription.insertNewObject(forEntityName: String(describing: Map.self), into: context) as! Map
			
			newMap.id = String(strHash(session.id!)) + String(describing: Date())
			newMap.current = true
			
			session.addToMaps(newMap)
			
			let PLN = Load.currencies().first{$0.name == "PLN"}
			session.currency = PLN
			
			CoreDataStack.saveContext()
			
			var devices = PackageService.pack.session.connectedPeers.map{$0.displayName}
			devices.append(UIDevice.current.name)
			
			UserDefaults.standard.set(true, forKey: "sessionIsActive")
			
			let action = NSMutableDictionary()
			let actionType = NSNumber(value: ActionType.sessionReceived.rawValue)
			
			action.setValue(actionType, forKey: "action")
			
			let sessionDictionary = packSessionForMessage(session)
			
			action.setValue(actionType, forKey: "action")
			action.setValue(sessionDictionary, forKey: "session")
			action.setValue(session.current, forKey: "setCurrent")
			
			PackageService.pack.send(action)
			NotificationCenter.default.post(name: .addedSession, object: session)
			return session
		}
		
		var currentSession = sessions.first(where: {$0.current == true})
		
		if currentSession == nil{
			currentSession = sessions.first
			currentSession?.current = true
		}
		
		return currentSession!
		
	}
	
    public static func packages(fromCurrentSession: Bool = true) -> [Package]{
        var packages: [Package] = []
		
		if fromCurrentSession{
            let session = Load.currentSession()
			
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
    
	public static func characters(usingVisibility: Bool = false) -> [Character]{
        var characters: [Character] = []
        
		let currentSession = Load.currentSession()
		characters = currentSession.characters?.sortedArray(using: [.sortCharacterById]) as! [Character]
		
		if usingVisibility {
			if let visibility = self.currentVisibility(){
				characters = characters.filter{$0.visibility == visibility}
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
	
	public static func currentMap(session: Session) -> Map{
		return session.maps?.filter({($0 as! Map).current}).first as! Map
	}
	
	public static func map(withId id: String) -> Map?{
		var map: Map?
		let mapFetch: NSFetchRequest<Map> = Map.fetchRequest()
		
		mapFetch.predicate = NSPredicate(format: "id == %@", id)
		
		do {
			map = try context.fetch(mapFetch).first
		}catch{
			print("error")
		}
		
		return map
	}
	
	public static func mapEntity(withId id: String) -> MapEntity?{
		var mapEntity: MapEntity?
		let mapEntityFetch: NSFetchRequest<MapEntity> = MapEntity.fetchRequest()
		
		mapEntityFetch.predicate = NSPredicate(format: "id == %@", id)
		
		do {
			mapEntity = try context.fetch(mapEntityFetch).first
		}catch{
			print("error")
		}
		
		return mapEntity
	}
	
	public static func currencies() -> [Currency]{
		var currencies: [Currency]!
		let currenciesFetch: NSFetchRequest<Currency> = Currency.fetchRequest()
		
		do {
			currencies = try context.fetch(currenciesFetch)
		}catch{
			print("error")
		}
		
		return currencies
	}
	
	public static func currentCurrency() -> Currency?{
		let session = Load.currentSession()
		
		return session.currency		
	}
	
	public static func visibilities() -> [Visibility]{
		let session = Load.currentSession()
		
		return session.visibility?.allObjects as! [Visibility]
	}
	
	public static func currentVisibility() -> Visibility?{
		let visibilities = Load.visibilities()
		
		return visibilities.first(where: {$0.current})
	}
	
}
