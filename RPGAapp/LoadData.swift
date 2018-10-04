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
            subCategories = try context.fetch(subCategoryFetch)
        }
        catch{
            print("error fetching")
        }
        
        return subCategories
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
	
	public static func currentExistingSession() -> Session?{
		let session = Load.sessions().first(where: {$0.current})
		
		return session
	}
	
	public static func currentSession() -> Session{
		
		let sessions = Load.sessions().filter{$0.current}
		
		if sessions.count == 0{
			let session = NSEntityDescription.insertNewObject(forEntityName: String(describing: Session.self), into: context) as! Session
			session.name = NSLocalizedString("Session", comment: "")
			session.gameMaster = UIDevice.current.name
			session.current = true
			session.id = String(strHash(session.name! + session.gameMaster! + String(describing: Date()) + String(myRand(100000))))
			
			let newMap = NSEntityDescription.insertNewObject(forEntityName: String(describing: Map.self), into: context) as! Map
			
			newMap.id = String(strHash(session.id!)) + String(describing: Date())
			newMap.current = true
			
			session.addToMaps(newMap)
			
			let PLN = Load.currencies().first{$0.name == "PLN"}
			session.currency = PLN
			
			CoreDataStack.saveContext()
			
			var devices = PackageService.pack.session.connectedPeers.map{$0.displayName}
			devices.append(UIDevice.current.name)
						
			let action = SessionReceived(session: session)			
			PackageService.pack.send(action: action)
			
			NotificationCenter.default.post(name: .sessionReceived, object: nil)
			return session
		}
		
		var currentSession = sessions.first(where: {$0.current == true})
		
		if currentSession == nil{
			currentSession = sessions.first
			currentSession?.current = true
		}
		
		return currentSession!
		
	}
	
	public static func packages(usingVisiblitiy: Bool = false) -> [Package]{
        var packages: [Package] = []
		
		guard let session = Load.currentExistingSession() else { return [] }
			
		packages = session.packages?.sortedArray(using: [.sortPackageByName,.sortPackageById]) as! [Package]
		
		if usingVisiblitiy {
			let visiblity = Load.currentVisibility()
			packages = packages.filter{$0.visibility == visiblity}
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
        
        drawSettingsFetch.sortDescriptors = [.sortDrawSettingByName]
        
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
        
		guard let currentSession = Load.currentExistingSession() else { return [] }
		characters = currentSession.characters?.sortedArray(using: [.sortCharacterById]) as! [Character]
		
		if usingVisibility {
			if let visibility = self.currentVisibility(){
				characters = characters.filter{$0.visibility == nil
											|| $0.visibility == visibility}
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
		let session = Load.currentExistingSession()
		
		if let currency = session?.currency{
			return currency
		}else{
			return currencies().first(where: {$0.name == "PLN"})
		}
	}
	
	public static func visibilities() -> [Visibility]{
		guard let session = Load.currentExistingSession() else { return [] }
		
		return session.visibility?.allObjects as! [Visibility]
	}
	
	public static func currentVisibility() -> Visibility?{
		let visibilities = Load.visibilities()
		
		return visibilities.first(where: {$0.current})
	}
	
	public static func visibility(with id: String) -> Visibility?{
		var visibility: Visibility?
		
		let visibilityFetch: NSFetchRequest<Visibility> = Visibility.fetchRequest()
		
		visibilityFetch.predicate = NSPredicate(format: "id == %@", id)
		
		do{
			visibility = try context.fetch(visibilityFetch).first
		}
		catch{
			print("error")
		}
		
		return visibility
	}
	
	public static func texture(with id: String) -> Texture?{
		let mapEntity = Load.mapEntity(withId: id)
		
		let texture = mapEntity?.texture
		
		return texture		
	}

	public static func itemAtributes() -> [ItemAtribute]{
		var attributes: [ItemAtribute] = []
		
		let attributeFetch: NSFetchRequest<ItemAtribute> = ItemAtribute.fetchRequest()
		
		do{
			attributes = try context.fetch(attributeFetch)
		}
		catch{
			print("error")
		}
		
		return attributes
	}
	
	public static var priceRange: (Double, Double){
		let priceList = Load.items().map{$0.price}
		return (priceList.min() ?? 0, priceList.max() ?? 0)
	}
}
