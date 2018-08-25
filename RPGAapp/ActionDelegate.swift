//
//  ActionDelegate.swift
//  RPGAapp
//
//  Created by Jakub on 12.11.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import CoreData
import Whisper

class ActionDelegate: PackageServiceDelegate{
	
	static var ad = ActionDelegate()	
	
    func received(_ action: NSMutableDictionary,from sender: MCPeerID) {
		
//		print(action)
		guard let actionNumber = action.value(forKey: "action") as? Int else { return }
		guard let actionType = ActionType(rawValue: actionNumber) else { return }
		let senderName = sender.displayName
					
		if actionType == ActionType.applicationDidEnterBackground{
			let message = senderName + " wyszedł z aplikacji"
			whisper(messege: message)
			
		}else if actionType == ActionType.itemSend{
			guard let characterId = action.value(forKey: "characterId") as? String else { return }
			let itemId = action.value(forKey: "itemId") as? String
			let itemCount = action.value(forKey: "itemCount") as? Int64
			
			let itemsId: [String]? = action.value(forKey: "itemsId") as? [String]
			let itemsCount: [Int64]? = action.value(forKey: "itemsCount") as? [Int64]
			
			guard let character: Character = Load.character(with: characterId) else { return }
			
			var request: ItemRequest? = nil
			
			if let id = itemId{
			
				if let item = Load.item(with: id){
					
					if let count = itemCount{
						addToEquipment(item: item, to: character, count: count)
					}else{
						addToEquipment(item: item, to: character)
					}
					
				}else {
					request = ItemRequest(with: [id], sender: sender, action: action)
				}
				
			}else if let count = itemsId?.count{
				var itemsToRequest: [String] = []
				
				for id in itemsId!{
					if Load.item(with: id) == nil{
						itemsToRequest.append(id)
					}
				}
				
				if itemsToRequest.count == 0{
					
					for itemNum in 0...count - 1{
						let id = itemsId![itemNum]
						
						if let item = Load.item(with: id){
							addToEquipment(item: item, to: character, count: (itemsCount?[itemNum])!)
						}
					}
					
				}else{
					request = ItemRequest(with: itemsToRequest, sender: sender, action: action)
				}
			}
			
			if let req = request {
				ItemRequester.rq.request(req)
			}
			
			CoreDataStack.saveContext()
			
			NotificationCenter.default.post(name: .equipmentChanged, object: nil)
			
		}else if actionType == ActionType.characterCreated{
			guard let characterId = action.value(forKey: #keyPath(Character.id)) as? String else { return }
			
			var newCharacter: Character
			
			let session = Load.currentSession()
			
			if let character = Load.character(with: characterId){
				newCharacter = character
				
			}else {
				newCharacter = NSEntityDescription.insertNewObject(forEntityName: String(describing: Character.self), into: CoreDataStack.managedObjectContext) as! Character
			
				session.addToCharacters(newCharacter)
			
				newCharacter.visibility = Load.currentVisibility()
				
				let newMapEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: MapEntity.self), into: CoreDataStack.managedObjectContext) as! MapEntity
			
				guard let mapEntityId = action.value(forKey: "mapEntityId") as? String else { return }
				guard let mapEntityPosX = action.value(forKey: "mapEntityPosX") as? Double else { return }
				guard let mapEntityPosY = action.value(forKey: "mapEntityPosY") as? Double else { return }
				
				newMapEntity.character = newCharacter
				newMapEntity.id = mapEntityId
				newMapEntity.x = mapEntityPosX
				newMapEntity.y = mapEntityPosY
				newMapEntity.map = Load.currentMap(session: session)
			}
			
			newCharacter.name = action.value(forKey: #keyPath(Character.name)) as? String
			newCharacter.health = (action.value(forKey: #keyPath(Character.health)) as? Double) ?? 0
			newCharacter.race = action.value(forKey: #keyPath(Character.race)) as? String
			newCharacter.id = action.value(forKey: #keyPath(Character.id)) as? String
			newCharacter.profession = action.value(forKey: #keyPath(Character.profession)) as? String
			
			CoreDataStack.saveContext()
			
			NotificationCenter.default.post(name: .reloadTeam, object: nil)
			
			let localizedNewCharacterString = NSLocalizedString("Added new character", comment: "")
			whisper(messege: localizedNewCharacterString)
			
			return
		}else if actionType == ActionType.itemAddedToPackge{
			let itemId = action.value(forKey: "itemId") as? String
			let itemHandlerId = action.value(forKey: "itemToAdd") as? String
			let itemHandlerCount = action.value(forKey: "itemsToAdd") as? Int64
			let itemsHandlerId = action.value(forKey: "itemsToAdd") as? NSArray
			let itemsHandlerCount = action.value(forKey: "itemsToAddCount") as? NSArray
			
			let context = CoreDataStack.managedObjectContext
			
			guard let packageId = action.value(forKey: "packageId") as? String else { return }
			
			var package = Load.packages(with: packageId)
			let allItems: [Item] = Load.items()
			
			if package == nil{
				guard let packageName = action.value(forKey: "packageName") as? String else { return }
				
				package = (NSEntityDescription.insertNewObject(forEntityName: String(describing: Package.self), into: context) as! Package)
				
				package?.name = packageName
				package?.id = packageId
				
				package?.visibility = Load.currentVisibility()
				
				let session = Load.currentSession()
				session.addToPackages(package!)
				CoreDataStack.saveContext()
				NotificationCenter.default.post(name: .createdPackage, object: nil)
			}
			
			var request: ItemRequest? = nil
			
			if itemId != nil{
				if let item = allItems.first(where: {$0.id == itemId}){
					add(item, to: package!, count: nil)
				}else{
					let subAction = NSMutableDictionary()
					
					let at = NSNumber(value: ActionType.itemAddedToPackge.rawValue)
					
					subAction.setValue(at, forKey: "action")
					subAction.setValue(packageId, forKey: "packageId")
					subAction.setValue(itemId, forKey: "itemId")
					
					request = ItemRequest(with: [itemId!], sender: sender, action: subAction)
				}
			}
			else if (itemHandlerId != nil){
				if let item = allItems.first(where: {$0.id == itemHandlerId}){
					add(item, to: package!, count: itemHandlerCount)
				}else{
					let subAction = NSMutableDictionary()
					
					let at = NSNumber(value: ActionType.itemAddedToPackge.rawValue)
					
					subAction.setValue(at, forKey: "action")
					subAction.setValue(packageId, forKey: "packageId")
					subAction.setValue(itemId, forKey: "itemId")
					subAction.setValue(itemHandlerCount, forKey: "itemsToAdd")
					
					request = ItemRequest(with: [itemId!], sender: sender, action: subAction)
				}
			}
			else if(itemsHandlerId != nil){
				let subAction = NSMutableDictionary()
				var itemsToRequest: [String] = []
				var itemsToRequestCount: [Int64] = []
				
				
				for i in 0...((itemsHandlerId?.count)! - 1){
					guard let id = itemsHandlerId?[i] as? String else { continue }
					guard let count = itemsHandlerCount?[i] as? Int64 else { continue }
					if let item = allItems.first(where: {$0.id == id}){
						add(item, to: package!, count: count)
					}else{
						itemsToRequest.append(id)
						itemsToRequestCount.append(count)
					}
				}
				
				if itemsToRequest.count > 0 {
				
					let at = NSNumber(value: ActionType.itemAddedToPackge.rawValue)
					
					subAction.setValue(at, forKey: "action")
					subAction.setValue(NSArray(array: itemsToRequest), forKey: "itemsToAdd")
					subAction.setValue(NSArray(array: itemsToRequestCount), forKey: "itemsToAddCount")
					
					request = ItemRequest(with: itemsToRequest, sender: sender, action: subAction)
					
				}
			}
			
			if let req = request{
				ItemRequester.rq.request(req)
			}
			
			NotificationCenter.default.post(name: .addedItemToPackage, object: nil)
		}else if actionType == ActionType.disconnectPeer{
			if (action.value(forKey: "peer") as? String) == UIDevice.current.name{
				PackageService.pack.session.disconnect()
			}
		}else if actionType == ActionType.itemDeletedFromCharacter{
			let itemId = action.value(forKey: "itemId") as? String
			let characterId = action.value(forKey: "characterId") as? String
			
			guard itemId != nil && characterId != nil else{
				return
			}
			
			let item: Item? = Load.item(with: itemId!)
			let character: Character? = Load.character(with: characterId!)
			
			if let handlerToRemove = (character?.equipment?.first(where: {($0 as! ItemHandler).item == item}) as? ItemHandler){
				character?.removeFromEquipment(handlerToRemove)
				
				NotificationCenter.default.post(name: .equipmentChanged, object: nil)
				
				CoreDataStack.saveContext()
			}
		}else if actionType == ActionType.sessionSwitched{
			NotificationCenter.default.post(name: .switchedSession, object: action)
			let sessionId = action.value(forKey: "sessionId") as! String
			
			let sessions: [Session] = Load.sessions()
			
			sessions.first(where: {$0.current == true})?.current = false
			
			sessions.first(where: {$0.id == sessionId})?.current = true
		}else if actionType == .sessionDeleted{
			guard UserDefaults.standard.bool(forKey: "syncSessionRemoval") == true else { return }
			
			let sessionId = action.value(forKey: "sessionId") as! String
			
			let context = CoreDataStack.managedObjectContext
			let sessions: [Session] = Load.sessions()
			
			if let session = sessions.first(where: {$0.id == sessionId}){
				let index = sessions.index(of: session)
				let indexPath = IndexPath(row: index! + 1, section: 1)
				context.delete(session)
				NotificationCenter.default.post(name: .sessionDeleted, object: indexPath)
			}
		}else if actionType == .packageCreated{
			let packageName = action.value(forKey: "packageName") as! String
			let packageId = action.value(forKey: "packageId") as! String
			
			let context = CoreDataStack.managedObjectContext
			let newPackage = NSEntityDescription.insertNewObject(forEntityName: String(describing: Package.self), into: context) as! Package
			
			newPackage.name = packageName
			newPackage.id = packageId
			
			newPackage.visibility = Load.currentVisibility()
			
			let session = Load.currentSession()
			
			session.addToPackages(newPackage)
			
			CoreDataStack.saveContext()
			
			NotificationCenter.default.post(name: .createdPackage, object: nil)
		}else if actionType == .packageDeleted{
			guard let packageId = action.value(forKey: "packageId") as? String else { return }
			guard let package = Load.packages(with: packageId) else { return }
			
			CoreDataStack.managedObjectContext.delete(package)
			
			CoreDataStack.saveContext()
			
			NotificationCenter.default.post(name: .createdPackage, object: nil) //same as deletePackage
		}else if actionType == .generatedRandomNumber{
			let number = action.value(forKey: "number") as! Int
			let message = NSLocalizedString("Drawn", comment: "") + " " + String(number)
			
			whisper(messege: message)
			
		}else if actionType == .addedAbilityToCharacter{
			guard let characterId = action.value(forKey: "characterId") as? String else {return}
			guard let abilityName = action.value(forKey: "abilityName") as? String else {return}
			guard let abilityId = action.value(forKey: "abilityId") as? String else {return}
			guard let abilityValue = action.value(forKey: "abilityValue") as? Int16 else {return}
			
			guard let character = Load.character(with: characterId) else {return}
			
			let context = CoreDataStack.managedObjectContext
			let newAbility = NSEntityDescription.insertNewObject(forEntityName: String(describing: Ability.self), into: context) as! Ability
			
			newAbility.name = abilityName
			newAbility.id = abilityId
			newAbility.value = abilityValue
			newAbility.character = character
			
			CoreDataStack.saveContext()
			
			NotificationCenter.default.post(name: .modifiedAbility, object: nil)
			
		}else if actionType == .valueOfAblilityChanged{
			guard let characterId = action.value(forKey: "characterId") as? String else {return}
			guard let abilityId = action.value(forKey: "abilityId") as? String else {return}
			guard let abilityValue = action.value(forKey: "abilityValue") as? Int16 else {return}
			
			guard let character = Load.character(with: characterId) else {return}
			
			guard let ability = character.abilities?.first(where: {($0 as! Ability).id == abilityId}) as? Ability else {return}
			ability.value = abilityValue

			CoreDataStack.saveContext()
			
			NotificationCenter.default.post(name: .valueOfAblitityChanged, object: abilityId)
			
		}else if actionType == .removeAbility{
			guard let characterId = action.value(forKey: "characterId") as? String else {return}
			guard let abilityId = action.value(forKey: "abilityId") as? String else {return}
			
			guard let character = Load.character(with: characterId) else { return }
			
			guard let ability = character.abilities?.first(where: {($0 as! Ability).id == abilityId}) as? Ability else { return }
			
			let contex = CoreDataStack.managedObjectContext
			
			character.removeFromAbilities(ability)
			contex.delete(ability)
			
			CoreDataStack.saveContext()
			
			NotificationCenter.default.post(name: .modifiedAbility, object: nil)
			
		}else if actionType == .removeCharacter{
			guard let characterId = action.value(forKey: "characterId") as? String else { return }
			
			guard let character = Load.character(with: characterId) else { return }
			
			let context = CoreDataStack.managedObjectContext
			
			context.delete(character)
			
			CoreDataStack.saveContext()
			
			NotificationCenter.default.post(name: .reloadTeam, object: nil)
			
		}else if actionType == .itemHandlerCountChanged{
			guard let characterId = action.value(forKey: "characterId") as? String else { return }
			guard let itemId = action.value(forKey: "itemId") as? String else { return }
			guard let itemCount = action.value(forKey: "itemCount") as? Int64 else { return }
			
			guard let character = Load.character(with: characterId) else { return }
			
			guard let handler = character.equipment?.first(where: {($0 as? ItemHandler)?.item?.id == itemId}) as? ItemHandler else { return }
			
			handler.count = itemCount
			
			CoreDataStack.saveContext()
			
			NotificationCenter.default.post(name: .equipmentChanged, object: nil)
		
		}else if actionType == ActionType.sessionReceived{
			guard let sessionData = action.value(forKey: "session") as? NSDictionary else { return }
			guard let sessionId = sessionData.value(forKey: "id") as? String else { return }
			
			if let session = Load.session(with: sessionId){
				let alert = UIAlertController(title: "receive session with id of exising session", message: "Do you want to replace it or keep local version?", preferredStyle: .alert)
				
				let alertReplace = UIAlertAction(title: "Replace", style: .default, handler: { (_) in
					let contex = CoreDataStack.managedObjectContext
					
					contex.delete(session)
					
					createSessionUsing(action: action, sender: sender)
					CoreDataStack.saveContext()
					
					NotificationCenter.default.post(name: .sessionReceived, object: nil)
					NotificationCenter.default.post(name: .reloadTeam, object: nil)
				})
				
				let alertKeep = UIAlertAction(title: "Keep", style: .default, handler: nil)
				
				alert.addAction(alertReplace)
				alert.addAction(alertKeep)
				
				let a = UIApplication.topViewController()
				
				a?.present(alert, animated: true, completion: nil)
				
			}else{
				createSessionUsing(action: action, sender: sender)
				
				CoreDataStack.saveContext()
				
				NotificationCenter.default.post(name: .sessionReceived, object: nil)
				NotificationCenter.default.post(name: .reloadTeam, object: nil)
			}
		}else if actionType == ActionType.itemsRequest{
			guard let itemsId = action.value(forKey: "itemsId") as? NSArray else { return }
			let requestId = action.value(forKey: "id")
			
			let response = NSMutableDictionary()
			response.setValue(ActionType.itemsRequestResponse.rawValue, forKey: "action")
			
			let itemsData = NSMutableArray()
			
			for case let itemId as String in itemsId{
				guard let item = Load.item(with: itemId) else { continue }
				let itemData = packItem(item)
				itemsData.add(itemData)
			}
			
			response.setValue(itemsData, forKey: "itemsData")
			response.setValue(requestId, forKey: "requestId")
			
			PackageService.pack.send(response, to: sender)
			
		}else if actionType == ActionType.itemsRequestResponse{
			guard let itemsData = action.value(forKey: "itemsData") as? NSArray else { return }
			let requestId = action.value(forKey: "id")
			
			for case let itemData as NSDictionary in itemsData{
				_ = unPackItem(from: itemData)
			}
			
			NotificationCenter.default.post(name: .receivedItemData, object: requestId)
		}else if actionType == ActionType.mapEntityMoved{
			guard let entityId = action.value(forKey: "entityId") as? String else { return }
			guard let posX = action.value(forKey: "posX") as? Double else { return }
			guard let posY = action.value(forKey: "posY") as? Double else { return }
			
			guard let entity = Load.mapEntity(withId: entityId) else { return }
			
			entity.x = posX
			entity.y = posY
			
			CoreDataStack.saveContext()
			
			let newPos = CGPoint(x: posX, y: posY)
			
			NotificationCenter.default.post(name: .mapEntityMoved, object: (entity, newPos))
			
			
		}else if actionType == ActionType.syncItemLists{
			let action = NSMutableDictionary()
			
			action.setValue(ActionType.requestedItemList.rawValue, forKey: "action")
			
			PackageService.pack.send(action)
			
			
		}else if actionType == ActionType.requestedItemList{
			let response = NSMutableDictionary()
			response.setValue(ActionType.recievedItemList.rawValue, forKey: "action")
			
			let itemList = NSArray(array: Load.items().map{$0.id})
			
			response.setValue(itemList, forKey: "itemList")
			
			PackageService.pack.send(response, to: sender)
			
			
		}else if actionType == ActionType.recievedItemList{
			let localItemList = Load.items().map{$0.id}
			
			let recievedItemList = (action.value(forKey: "itemList") as! NSArray) as! [String]
			
			let requestList = recievedItemList.filter{!localItemList.contains($0)}
			
			let action = NSMutableDictionary()
			action.setValue(ActionType.itemsRequest.rawValue, forKey: "action")
			
			action.setValue(NSArray(array: requestList), forKey: "itemsId")
			
			PackageService.pack.send(action, to: sender)
		}else if actionType == ActionType.sendImage{
			DispatchQueue.global().async {
				let imageData = action.value(forKey: "imageData") as? NSData
				
				let contex = CoreDataStack.managedObjectContext
				
				let texture: Texture!
				
				if let mapId = action.value(forKey: "mapId") as? String{
					
					if let map = Load.map(withId: mapId){
						
						if let exisitingTexture = map.background{
							texture = exisitingTexture
						}else{
							texture =  NSEntityDescription.insertNewObject(forEntityName: String(describing: Texture.self), into: contex) as! Texture
							map.background = texture
						}
						
						texture.data = imageData!
						
						DispatchQueue.main.async {
							NotificationCenter.default.post(name: .mapBackgroundChanged, object: nil)
						}
					}
					
				}else if let entityId = action.value(forKey: "entityId") as? String{
					
					if let entity = Load.mapEntity(withId: entityId){
						
						if let exisitingTexture = entity.texture{
							texture = exisitingTexture
						}else{
							texture =  NSEntityDescription.insertNewObject(forEntityName: String(describing: Texture.self), into: contex) as! Texture
							entity.texture = texture
						}						
						
						DispatchQueue.main.async {
							NotificationCenter.default.post(name: .mapEntityTextureChanged, object: entity)
						}
					}
					
				}
				
				CoreDataStack.saveContext()
			}
		}else if actionType == ActionType.currencyCreated{
			guard let currencyData = action.value(forKey: "currencyData") as? NSMutableDictionary else { return }

			_ = unPackCurrency(currencyData: currencyData)

			NotificationCenter.default.post(name: .currencyCreated, object: nil)
		}else if actionType == ActionType.visibilityCreated{
			guard let name = action.value(forKey: "name") as? String else { return }
			guard let id = action.value(forKey: "id") as? String else { return }
			
			let context = CoreDataStack.managedObjectContext
			let visibility = NSEntityDescription.insertNewObject(forEntityName: String(describing: Visibility.self), into: context) as! Visibility
			
			visibility.name = name
			visibility.id = id
			visibility.session = Load.currentSession()
			
			CoreDataStack.saveContext()
			
			NotificationCenter.default.post(name: .visibilityCreated, object: nil)
		}else if actionType == ActionType.characterVisibilityChanged{
			guard let characterId = action.value(forKey: "characterId") as? String else { return }
			guard let visibilityId = action.value(forKey: "visibilityId") as? String else { return }
			
			guard let character = Load.character(with: characterId) else { return }
			
			var visibility = Load.visibility(with: visibilityId)
			
			if visibility == nil{
				let context = CoreDataStack.managedObjectContext
				visibility = NSEntityDescription.insertNewObject(forEntityName: String(describing: Visibility.self), into: context) as? Visibility
				
				guard let visibilityName = action.value(forKey: "visibilityName") as? String else { return }
				
				visibility?.name = visibilityName
				visibility?.id = visibilityId
				visibility?.session = Load.currentSession()
			}
			
			character.visibility = visibility
			
			CoreDataStack.saveContext()
			
			NotificationCenter.default.post(name: .visibilityCreated, object: nil)
			NotificationCenter.default.post(name: .reloadTeam, object: nil)
		}
    }
	
	func receiveLocally(_ action: NSMutableDictionary){
		
		let packServ = PackageService.pack
		let localId = packServ.myPeerID
		
		received(action, from: localId)
	}

    func lost(_ peer: MCPeerID) {
        let message = NSLocalizedString("Lost connection with", comment: "") + " " + peer.displayName
        whisper(messege: message)
    }
    
    func found(_ peer: MCPeerID) {
        DispatchQueue.main.async{
            let pack = PackageService.pack
            var connectedDevices = pack.session.connectedPeers.map({$0.displayName})
            connectedDevices.append(UIDevice.current.name)
            
            let devices = NSSet(array: connectedDevices)
            
            let session = Load.currentSession()
            
            let sessionDevices = session.devices as? NSSet
            
            print(devices)
            print(sessionDevices as Any)
            if sessionDevices != nil && sessionDevices! == devices && devices.count > 0{               
                UserDefaults.standard.set(true, forKey: "sessionIsActive")
            }else{
                let message = NSLocalizedString("Reconneced with", comment: "") + " " + peer.displayName
                whisper(messege: message)
            }
        }
    }
    
    func connectedDevicesChanged(manager: PackageService, connectedDevices: [String]) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .connectedDevicesChanged, object: nil)
        }
    }
}
