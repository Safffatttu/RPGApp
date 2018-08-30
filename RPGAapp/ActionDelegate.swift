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
	
    func received(_ actionData: ActionData, from sender: MCPeerID) {
		
		print(actionData)
		guard let actionNumber = actionData.value(forKey: "action") as? Int else { return }
		guard let actionType = ActionType(rawValue: actionNumber) else { return }
		
		if actionType == .applicationDidEnterBackground{
			let message = "\(sender.displayName) \(NSLocalizedString("exited application", comment: ""))"
			whisper(messege: message)
			
		}else if actionType == .itemCharacterAdded{
			let action = ItemCharacterAdded(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .characterCreated{
			let action = CharacterCreated(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .itemPackageAdded{
			let action = ItemPackageAdded(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .disconnectPeer{
			if (actionData.value(forKey: "peer") as? String) == UIDevice.current.name{
				PackageService.pack.session.disconnect()
			}
		}else if actionType == .itemCharacterDeleted{
			let action = ItemCharacterDeleted(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .sessionSwitched{
			let action = SessionSwitched(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .sessionDeleted{
			let action = SessionDeleted(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .packageCreated{
			let action = PackageCreated(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .packageDeleted{
			let action = PackageDeleted(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .generatedRandomNumber{
			let action = GeneratedRandomNumber(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .abilityAdded{
			let action = AbilityAdded(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .abilityValueChanged{
			let action = AbilityValueChanged(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .abilityRemoved{
			let action = AbilityRemoved(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .characterRemoved{
			let action = CharacterRemoved(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .itemCharacterChanged{
			let action = ItemCharacterChanged(actionData: actionData, sender: sender)
			action.execute()
		
		}else if actionType == .sessionReceived{
			guard let sessionData = actionData.value(forKey: "session") as? NSDictionary else { return }
			guard let sessionId = sessionData.value(forKey: "id") as? String else { return }
			
			if let session = Load.session(with: sessionId){
				let alert = UIAlertController(title: "receive session with id of exising session", message: "Do you want to replace it or keep local version?", preferredStyle: .alert)
				
				let alertReplace = UIAlertAction(title: "Replace", style: .default, handler: { (_) in
					let contex = CoreDataStack.managedObjectContext
					
					contex.delete(session)
					
					guard let newSession = createSessionUsing(action: actionData, sender: sender) else { return }
					
					let textureToRequest = getTextureId(from: newSession)
					requestTexuturesFrom(id: textureToRequest)
					
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
				guard let newSession = createSessionUsing(action: actionData, sender: sender) else { return }
				
				CoreDataStack.saveContext()
				
				NotificationCenter.default.post(name: .sessionReceived, object: nil)
				NotificationCenter.default.post(name: .reloadTeam, object: nil)
				
				let textureToRequest = getTextureId(from: newSession)
				requestTexuturesFrom(id: textureToRequest)
				
			}
		
		}else if actionType == .itemsRequest{
			guard let itemsId = actionData.value(forKey: "itemsId") as? NSArray else { return }
			let requestId = actionData.value(forKey: "id")
			
			let response = NSMutableDictionary()
			response.setValue(ActionType.itemsRequestResponse.rawValue, forKey: "actionData")
			
			let itemsData = NSMutableArray()
			
			for case let itemId as String in itemsId{
				guard let item = Load.item(with: itemId) else { continue }
				let itemData = packItem(item)
				itemsData.add(itemData)
			}
			
			response.setValue(itemsData, forKey: "itemsData")
			response.setValue(requestId, forKey: "requestId")
			
			PackageService.pack.send(response, to: sender)
			
		}else if actionType == .itemsRequestResponse{
			guard let itemsData = actionData.value(forKey: "itemsData") as? NSArray else { return }
			let requestId = actionData.value(forKey: "id")
			
			for case let itemData as NSDictionary in itemsData{
				_ = unPackItem(from: itemData)
			}
			
			NotificationCenter.default.post(name: .receivedItemData, object: requestId)
		}else if actionType == ActionType.mapEntityMoved{
			guard let entityId = actionData.value(forKey: "entityId") as? String else { return }
			guard let posX = actionData.value(forKey: "posX") as? Double else { return }
			guard let posY = actionData.value(forKey: "posY") as? Double else { return }
			
			guard let entity = Load.mapEntity(withId: entityId) else { return }
			
			entity.x = posX
			entity.y = posY
			
			CoreDataStack.saveContext()
			
			let newPos = CGPoint(x: posX, y: posY)
			
			NotificationCenter.default.post(name: .mapEntityMoved, object: (entity, newPos))
			
			
		}else if actionType == .itemListSync{
			let actionData = NSMutableDictionary()
			
			actionData.setValue(ActionType.itemListRequested.rawValue, forKey: "actionData")
			
			PackageService.pack.send(actionData)
			
			
		}else if actionType == .itemListRequested{
			let response = NSMutableDictionary()
			response.setValue(ActionType.itemListRecieved.rawValue, forKey: "actionData")
			
			let itemList = NSArray(array: Load.items().flatMap{$0.id})
			
			response.setValue(itemList, forKey: "itemList")
			
			PackageService.pack.send(response, to: sender)
			
		}else if actionType == .itemListRecieved{
			let localItemList = Load.items().map{$0.id!}
			
			let recievedItemList = (actionData.value(forKey: "itemList") as! NSArray) as! [String]
			
			let requestList = recievedItemList.filter{itemId in
				!localItemList.contains(itemId)
			}
			
			let actionData = NSMutableDictionary()
			actionData.setValue(ActionType.itemsRequest.rawValue, forKey: "actionData")
			
			actionData.setValue(NSArray(array: requestList), forKey: "itemsId")
			
			PackageService.pack.send(actionData, to: sender)
			
		}else if actionType == .textureSend{
			guard let imageData = actionData.value(forKey: "imageData") as? NSData else { return }
				
			let texture: Texture
			let contex = CoreDataStack.managedObjectContext
	
			if let mapId = actionData.value(forKey: "mapId") as? String{
				
				guard let map = Load.map(withId: mapId) else { return }
				
				if let exisitingTexture = map.background{
					texture = exisitingTexture
				}else{
					texture =  NSEntityDescription.insertNewObject(forEntityName: String(describing: Texture.self), into: contex) as! Texture
					map.background = texture
				}
				
				texture.data = imageData
				
				CoreDataStack.saveContext()
				
				NotificationCenter.default.post(name: .mapBackgroundChanged, object: nil)
				
			}else if let entityId = actionData.value(forKey: "entityId") as? String{
				
				guard let entity = Load.mapEntity(withId: entityId) else { return }
				
				if let exisitingTexture = entity.texture{
					texture = exisitingTexture
				}else{
					texture =  NSEntityDescription.insertNewObject(forEntityName: String(describing: Texture.self), into: contex) as! Texture
					entity.texture = texture
				}
				
				texture.data = imageData
		
				CoreDataStack.saveContext()
				
				NotificationCenter.default.post(name: .mapEntityTextureChanged, object: entity)
			}
			
		}else if actionType == .currencyCreated{
			guard let currencyData = actionData.value(forKey: "currencyData") as? NSMutableDictionary else { return }

			_ = unPackCurrency(currencyData: currencyData)

			NotificationCenter.default.post(name: .currencyCreated, object: nil)
			
		}else if actionType == .visibilityCreated{
			guard let name = actionData.value(forKey: "name") as? String else { return }
			guard let id = actionData.value(forKey: "id") as? String else { return }
			
			let context = CoreDataStack.managedObjectContext
			let visibility = NSEntityDescription.insertNewObject(forEntityName: String(describing: Visibility.self), into: context) as! Visibility
			
			visibility.name = name
			visibility.id = id
			visibility.session = Load.currentSession()
			
			CoreDataStack.saveContext()
			
			NotificationCenter.default.post(name: .visibilityCreated, object: nil)
			NotificationCenter.default.post(name: .reloadTeam, object: nil)
			
		}else if actionType == .characterVisibilityChanged{
			guard let characterId = actionData.value(forKey: "characterId") as? String else { return }
			guard let character = Load.character(with: characterId) else { return }
			
			if let visibilityId = actionData.value(forKey: "visibilityId") as? String{
				var visibility = Load.visibility(with: visibilityId)
				
				if visibility == nil{
					let context = CoreDataStack.managedObjectContext
					visibility = NSEntityDescription.insertNewObject(forEntityName: String(describing: Visibility.self), into: context) as? Visibility
					
					guard let visibilityName = actionData.value(forKey: "visibilityName") as? String else { return }
					
					visibility?.name = visibilityName
					visibility?.id = visibilityId
					visibility?.session = Load.currentSession()
				}
				
				character.visibility = visibility
			
			}else{
				character.visibility = nil
			}
			
			CoreDataStack.saveContext()
			
			NotificationCenter.default.post(name: .visibilityCreated, object: nil)
			NotificationCenter.default.post(name: .reloadTeam, object: nil)
			
		}else if actionType == .itemDeletedPackage{
			guard let packageId = actionData.value(forKey: "packageId") as? String else { return }
			guard let itemId = actionData.value(forKey: "itemId") as? String else { return }
			
			guard let package = Load.packages(with: packageId) else { return }
			guard let itemHandlerToRemove = package.items?.first(where: {($0 as! ItemHandler ).item?.id == itemId}) as? ItemHandler else { return }
			
			package.removeFromItems(itemHandlerToRemove)
			
			let context = CoreDataStack.managedObjectContext
			context.delete(itemHandlerToRemove)
			
			CoreDataStack.saveContext()
			
			NotificationCenter.default.post(name: .addedItemToPackage, object: nil)
			
		}else if actionType == .textureRequest{
			let entityId = actionData.value(forKey: "entityId") as? String
			let mapId = actionData.value(forKey: "mapId") as? String
			
			var texture: Texture?
			
			if let id = entityId {
				texture = Load.texture(with: id)
			}else if let id = mapId {
				texture = Load.map(withId: id)?.background
			}else{
				return
			}
			
			guard let imageData = texture?.data else { return }
			
			let actionData = NSMutableDictionary()
			let actionType = NSNumber(value: ActionType.textureSend.rawValue)
			
			actionData.setValue(actionType, forKey: "actionData")
			actionData.setValue(imageData, forKey: "imageData")
			
			actionData.setValue(entityId, forKey: "entityId")
			actionData.setValue(mapId, forKey: "mapId")
			
			PackageService.pack.send(actionData)
		}
    }
	
	func receiveLocally(_ actionData: NSMutableDictionary){
		
		let packServ = PackageService.pack
		let localId = packServ.myPeerID
		
		received(actionData, from: localId)
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
