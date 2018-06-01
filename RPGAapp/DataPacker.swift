//
//  DataPacker.swift
//  RPGAapp
//
//  Created by Jakub on 12.05.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import CoreData
import MultipeerConnectivity

func packSessionForMessage(_ session: Session) -> NSDictionary{
	let current = session.current
	//let devices = NSArray(array: (session.devices as! NSSet).allObjects)
	let gameMaster = session.gameMaster
	let gameMasterName = session.gameMasterName
	let id = session.id
	let name = session.name
	
	let charactersToSend = NSMutableArray()
	
	for case let character as Character in session.characters! {
		let characterDict = NSMutableDictionary()
		characterDict.setValue(character.name, forKey: "name")
		characterDict.setValue(character.id, forKey: "id")
		characterDict.setValue(character.health, forKey: "health")
		characterDict.setValue(character.profession, forKey: "profession")
		characterDict.setValue(character.race, forKey: "race")
		
		let characterItems = NSMutableArray()
		
		for case let handler as ItemHandler in character.equipment!{
			let handlerDict = NSMutableDictionary()
			handlerDict.setValue(handler.item?.id, forKey: "itemId")
			handlerDict.setValue(handler.count, forKey: "count")
			
			characterItems.add(handlerDict)
		}
		
		characterDict.setValue(characterItems, forKey: "items")
		
		let characterAbilities = NSMutableArray()
		
		for case let ability as Ability in character.abilities!{
			let abilityDict = NSMutableDictionary()
			abilityDict.setValue(ability.name, forKey: "name")
			abilityDict.setValue(ability.id, forKey: "id")
			abilityDict.setValue(ability.value, forKey: "value")
			
			characterAbilities.add(abilityDict)
		}
		
		characterDict.setValue(characterAbilities, forKey: "abilities")
		
		charactersToSend.add(characterDict)
	}
	
	let packages = NSMutableArray()
	
	for case let package as Package in session.packages! {
		let packageDict = NSMutableDictionary()
		packageDict.setValue(package.name, forKey: "name")
		packageDict.setValue(package.id, forKey: "id")
		
		let packageItems = NSMutableArray()
		
		for case let handler as ItemHandler in package.items!{
			let handlerDict = NSMutableDictionary()
			handlerDict.setValue(handler.item?.id, forKey: "itemId")
			handlerDict.setValue(handler.count, forKey: "count")
			
			packageItems.add(handlerDict)
		}
		
		packageDict.setValue(packageItems, forKey: "items")
		
		packages.add(packageDict)
	}
	
	let maps = NSMutableArray()
	
	for case let map as Map in session.maps!{
		let mapDict = NSMutableDictionary()
		
		let mapEntities = NSMutableArray()
		
		for case let mapEnt as MapEntity in map.entities!{
			let mapEntDict = NSMutableDictionary()
			
			mapEntDict.setValue(mapEnt.id, forKey: "id")
			mapEntDict.setValue(mapEnt.x, forKey: "posX")
			mapEntDict.setValue(mapEnt.y, forKey: "posY")
			mapEntDict.setValue(mapEnt.character?.id, forKey: "characterId")
			
			mapEntities.add(mapEntDict)
		}
		
		mapDict.setValue(map.id, forKey: "id")
		mapDict.setValue(map.name, forKey: "name")
		mapDict.setValue(map.current, forKey: "current")
		mapDict.setValue(map.x, forKey: "posX")
		mapDict.setValue(map.y, forKey: "posY")
		mapDict.setValue(mapEntities, forKey: "mapEntities")
	
		maps.add(mapDict)
	}
	
	let dictionary = NSMutableDictionary()
	dictionary.setValue(current, forKey: "current")
	//dictionary.setValue(devices, forKey: "devices")
	dictionary.setValue(gameMaster, forKey: "gameMaster")
	dictionary.setValue(gameMasterName, forKey: "gameMasterName")
	dictionary.setValue(id, forKey: "id")
	dictionary.setValue(name, forKey: "name")
	dictionary.setValue(charactersToSend, forKey: "characters")
	dictionary.setValue(packages, forKey: "packages")
	dictionary.setValue(maps, forKey: "maps")
	
	return dictionary
}

func unPackSession(from dictionary: NSDictionary) -> Session? {
	guard let name = dictionary.value(forKey: "name") as? String else { return nil }
	guard let id = dictionary.value(forKey: "id") as? String else { return nil }
	
	let gameMaster = dictionary.value(forKey: "gameMaster") as? String
	let gameMasterName = dictionary.value(forKey: "gameMasterName") as? String
	let devices = dictionary.value(forKey: "devices") as? NSArray
	
	guard let allCharactersDict = dictionary.value(forKey: "characters") as? NSArray else { return nil }
	guard let allPackagesDict = dictionary.value(forKey: "packages") as? NSArray else { return nil }
	guard let allMapsDict = dictionary.value(forKey: "maps") as? NSArray else { return nil }
	
	let context = CoreDataStack.managedObjectContext
	
	if let previousSession = Load.session(with: id) {
		context.delete(previousSession)
	}
	
	let session = NSEntityDescription.insertNewObject(forEntityName: String(describing: Session.self), into: context) as! Session
	
	session.name = name
	session.id = id
	session.gameMaster = gameMaster
	session.gameMasterName = gameMasterName
	//session.devices	= NSSet(array: devices as! [Any])
	
	for case let characterDict as NSDictionary in allCharactersDict{
		
		guard let characterName = characterDict.value(forKey: "name") as? String else { continue }
		guard let characterId = characterDict.value(forKey: "id") as? String else { continue }
		guard let characterHealth = characterDict.value(forKey: "health") as? Double else { continue }
		let characterProfession = characterDict.value(forKey: "profession") as? String
		let characterRace = characterDict.value(forKey: "race") as? String
		
		let newCharacter = NSEntityDescription.insertNewObject(forEntityName: String(describing: Character.self), into: context) as! Character
		
		newCharacter.name = characterName
		newCharacter.id = characterId
		newCharacter.health = characterHealth
		newCharacter.profession = characterProfession
		newCharacter.race = characterRace
		
		guard let items = characterDict.value(forKey: "items") as? NSArray else { continue }
		
		for case let item as NSDictionary in items {
			guard let itemId = item.value(forKey: "itemId") as? String else { continue }
			guard let itemCount = item.value(forKey: "count") as? Int64 else { continue }
			
			guard let itemToAdd = Load.item(with: itemId) else { continue }
			
			let handler = NSEntityDescription.insertNewObject(forEntityName: String(describing: ItemHandler.self), into: context) as! ItemHandler
			
			handler.item = itemToAdd
			handler.count = itemCount
			
			newCharacter.addToEquipment(handler)
		}
		
		
		guard let abilities = characterDict.value(forKey: "abilities") as? NSArray else { continue }
		
		for case let abilityDict as NSDictionary in abilities {
			guard let abilityName = abilityDict.value(forKey: "name") as? String else { continue }
			guard let abilityId = abilityDict.value(forKey: "id") as? String else { continue }
			guard let abilityValue = abilityDict.value(forKey: "value") as? Int16 else { continue }
			
			let ability = NSEntityDescription.insertNewObject(forEntityName: String(describing: Ability.self), into: context) as! Ability
			
			ability.name = abilityName
			ability.id = abilityId
			ability.value = abilityValue
			
			newCharacter.addToAbilities(ability)
		}
		
		session.addToCharacters(newCharacter)
	}
	
	for case let packageDict as NSDictionary in allPackagesDict{
		
		guard let packageName = packageDict.value(forKey: "name") as? String else { continue }
		guard let packageId = packageDict.value(forKey: "id") as? String else { continue }
		guard let packageItems = packageDict.value(forKey: "items") as? NSArray else { continue }
		
		let package = NSEntityDescription.insertNewObject(forEntityName: String(describing: Package.self), into: context) as! Package
		
		package.name = packageName
		package.id = packageId
		
		for case let item as NSDictionary in packageItems {
			guard let itemId = item.value(forKey: "itemId") as? String else { continue }
			guard let itemCount = item.value(forKey: "count") as? Int64 else { continue }
			
			guard let itemToAdd = Load.item(with: itemId) else { continue }
			
			let handler = NSEntityDescription.insertNewObject(forEntityName: String(describing: ItemHandler.self), into: context) as! ItemHandler
			
			handler.item = itemToAdd
			handler.count = itemCount
			
			package.addToItems(handler)
		}
		
		session.addToPackages(package)
	}
	
	for case let mapDict as NSDictionary in allMapsDict{
		
		let mapName = mapDict.value(forKey: "name") as? String
		guard let mapId = mapDict.value(forKey: "id") as? String else { continue }
		guard let mapPosX = mapDict.value(forKey: "posX") as? Double else { continue }
		guard let mapPosY = mapDict.value(forKey: "posY") as? Double else { continue }
		guard let mapCurrent = mapDict.value(forKey: "current") as? Bool else { continue }
		
		guard let allMapEntities = mapDict.value(forKey: "mapEntities") as? NSArray else { continue }
		
		let map = NSEntityDescription.insertNewObject(forEntityName: String(describing: Map.self), into: context) as! Map
		
		for case let mapEntDict as NSDictionary in allMapEntities{
			
			guard let mapEntId = mapEntDict.value(forKey: "id") as? String else { continue }
			guard let mapEntPosX = mapEntDict.value(forKey: "posX") as? Double else { continue }
			guard let mapEntPosY = mapEntDict.value(forKey: "posY") as? Double else { continue }
			guard let mapEntCharacterId = mapEntDict.value(forKey: "characterId") as? String else { continue }

			let mapEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: MapEntity.self), into: context) as! MapEntity
			
			mapEntity.id = mapEntId
			mapEntity.x = mapEntPosX
			mapEntity.y = mapEntPosY
			
			guard let character = session.characters?.first(where: {($0 as? Character)?.id == mapEntCharacterId}) as? Character else { continue }
			
			character.mapRepresentation = mapEntity
			map.addToEntities(mapEntity)
		}
		
		map.id = mapId
		map.name = mapName
		map.x = mapPosX
		map.y = mapPosY
		map.current = mapCurrent
		
		session.addToMaps(map)
	}
	
	CoreDataStack.saveContext()
	
	return session
}

func packItem(_ item: Item) -> NSDictionary {
	let itemDict = NSMutableDictionary()
	
	itemDict.setValue(item.id, forKey: "id")
	itemDict.setValue(item.item_description, forKey: "item_description")
	itemDict.setValue(item.measure, forKey: "measure")
	itemDict.setValue(item.name, forKey: "name")
	itemDict.setValue(item.price, forKey: "price")
	itemDict.setValue(item.quantity, forKey: "quantity")
	itemDict.setValue(item.rarity, forKey: "rarity")
	itemDict.setValue(item.category?.name, forKey: "categoryName")
	itemDict.setValue(item.subCategory?.name, forKey: "subCategoryName")
	
	if let itemAtributes = item.itemAtribute?.allObjects as? [ItemAtribute]{
		let atributesDict = NSMutableArray()
		
		for atribute in itemAtributes{
			let atributeDict = NSMutableDictionary()
			
			atributeDict.setValue(atribute.name, forKey: "name")
			atributeDict.setValue(atribute.priceMod, forKey: "priceMod")
			atributeDict.setValue(atribute.rarityMod, forKey: "rarityMod")
			atributeDict.setValue(atribute.id, forKey: "id")
			
			atributesDict.add(atributeDict)
		}
		
		itemDict.setValue(atributesDict, forKey: "atributes")
		
	}
	
	return NSDictionary(dictionary: itemDict)
}

func unPackItem(from itemDictionary: NSDictionary) -> Item{
	let id = itemDictionary.value(forKey: "id") as? String
	let item_description = itemDictionary.value(forKey: "item_description") as? String
	let measure = itemDictionary.value(forKey: "measure") as? String
	let name = itemDictionary.value(forKey: "name") as? String
	let price = itemDictionary.value(forKey: "price") as! Double
	let quantity = itemDictionary.value(forKey: "quantity") as! Int16
	let rarity = itemDictionary.value(forKey: "rarity") as! Int16
	let categoryName = itemDictionary.value(forKey: "categoryName") as? String
	let subCategoryName = itemDictionary.value(forKey: "subCategoryName") as? String
	
	
	let category = Load.categories().first(where: {$0.name == categoryName})
	let subCategory = Load.subCategories().first(where: {$0.name == subCategoryName})
	
	let context = CoreDataStack.managedObjectContext
	let item = NSEntityDescription.insertNewObject(forEntityName: String(describing: Item.self), into: context) as! Item
	
	item.id = id
	item.item_description = item_description
	item.measure = measure
	item.name = name
	item.price = price
	item.quantity = quantity
	item.rarity = rarity
	item.category = category
	item.subCategory = subCategory
	
	CoreDataStack.saveContext()
	
	return item
}

func checkSessionDataForNotKnowIds(sessionData: NSDictionary) -> [String]{
	var requestList: [String] = []
	
	guard let allCharactersDict = sessionData.value(forKey: "characters") as? NSArray else { return requestList }
	
	let itemsIdList = Load.items().map({$0.id})
	
	for case let characterDict as NSDictionary in allCharactersDict{
		guard let items = characterDict.value(forKey: "items") as? NSArray else { continue }
		
		for case let item as NSDictionary in items {
			
			guard let itemId = item.value(forKey: "itemId") as? String else { continue }
			
			if !itemsIdList.contains(where: {$0 == itemId}){
				requestList.append(itemId)
			}
			
		}
	}
	
	guard let allPackageDict = sessionData.value(forKey: "packages") as? NSArray else { return  requestList }
	
	for case let packgeDict as NSDictionary in allPackageDict{
		guard let packageItems = packgeDict.value(forKey: "items") as? NSArray else { return requestList }
		
		for case let packgeItemHandler as NSDictionary in packageItems{
 			guard let itemId = packgeItemHandler.value(forKey: "itemId") as? String else { return requestList }
			
			if !itemsIdList.contains(where: {$0 == itemId}){
					requestList.append(itemId)
				}
		}
	}
	
	return requestList
}

func createSessionUsing(action: NSMutableDictionary, sender: MCPeerID){
	
	guard let data = action.value(forKey: "session") as? NSDictionary else { return }
	
	let itemsToRequest = checkSessionDataForNotKnowIds(sessionData: data)
	
	guard itemsToRequest.count == 0 else {
		
		let request = ItemRequest(with: itemsToRequest, sender: sender, action: action)
		
		ItemRequester.request(request)
		
		return
	}
	
	guard let newSession = unPackSession(from: data) else { return }
	
	if let setCurrent = data.value(forKey: "current") as? Bool{
		if setCurrent {
			Load.sessions().first(where: {$0.current})?.current = false
			newSession.current = setCurrent
		}
	}
}
