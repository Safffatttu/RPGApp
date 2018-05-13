//
//  ActionDelegate.swift
//  RPGAapp
//
//  Created by Jakub on 12.11.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import Popover
import MultipeerConnectivity
import CoreData
import Whisper

class ActionDelegate: NSObject, PackageServiceDelegate{
    
    func recieved(_ action: NSMutableDictionary,from sender: MCPeerID, manager: PackageService) {
        DispatchQueue.main.sync{
            let actionType = ActionType(rawValue: action.value(forKey: "action") as! Int)
            let senderName = sender.displayName
            print(action)
            
            if actionType == ActionType.applicationDidEnterBackground{
                let message = senderName + " wyszedł z aplikacji"
                whisper(messege: message)
            }else if actionType == ActionType.itemSend{
                let characterId = action.value(forKey: "characterId") as? String
                let itemId = action.value(forKey: "itemId") as? String
                let itemCount = action.value(forKey: "itemCount") as? Int64
                
                let itemsId: [String]? = action.value(forKey: "itemsId") as? [String]
                let itemsCount: [Int64]? = action.value(forKey: "itemsCount") as? [Int64]
                
                guard characterId != nil else{
                    return
                }
                
                let character: Character? = Load.character(with: characterId!)
                var item: Item? = nil
                

                guard character != nil else{
                    return
                }
                
                if let id = itemId{
                
                    item = Load.item(with: id)
                
                    guard item != nil else {
                        return
                    }
                    
                    if let count = itemCount{
                        addToEquipment(item: item!, to: character!, count: count)
                    }else{
                        addToEquipment(item: item!, to: character!)
                    }
                }else if let count = itemsId?.count{
                    for itemNum in 0...count - 1{
                        if let id = itemsId?[itemNum]{
                            item = Load.item(with: id)
                        }
                        guard item != nil else {
                            return
                        }
                        
                        addToEquipment(item: item!, to: character!, count: (itemsCount?[itemNum])!)
                    }
                }
                
                CoreDataStack.saveContext()
                
                NotificationCenter.default.post(name: .itemAddedToCharacter, object: action)
            }else if actionType == ActionType.characterCreated{
                let newCharacter = NSEntityDescription.insertNewObject(forEntityName: String(describing: Character.self), into: CoreDataStack.managedObjectContext) as! Character
                
                newCharacter.name = action.value(forKey: #keyPath(Character.name)) as? String
                newCharacter.health = action.value(forKey: #keyPath(Character.health)) as! Double
                newCharacter.race = action.value(forKey: #keyPath(Character.race)) as? String
                newCharacter.id = action.value(forKey: #keyPath(Character.id)) as? String
                newCharacter.profession = action.value(forKey: #keyPath(Character.profession)) as? String
                
                let session = getCurrentSession()
                
                session.addToCharacters(newCharacter)
                
                CoreDataStack.saveContext()
                
                NotificationCenter.default.post(name: .reloadTeam, object: nil)
                
                whisper(messege: "Dodano nową postać")
            }else if actionType == ActionType.itemAddedToPackge{
                let itemId = action.value(forKey: "itemId") as? String
                let itemHandlerId = action.value(forKey: "itemToAdd") as? String
                let itemHandlerCount = action.value(forKey: "itemsToAdd") as? Int64
                let itemsHandlerId = action.value(forKey: "itemsToAdd") as? NSArray
                let itemsHandlerCount = action.value(forKey: "itemsToAddCount") as? NSArray
                
                let context = CoreDataStack.managedObjectContext
                
                let packageName = action.value(forKey: "packageName") as! String
                let packageId = action.value(forKey: "packageId") as! String
                
                var package = Load.packages(with: packageId)
                let allItems: [Item] = Load.items()
                
                if package == nil{
                    package = (NSEntityDescription.insertNewObject(forEntityName: String(describing: Package.self), into: context) as! Package)
                    package?.name = packageName
                    package?.id = packageId
                    
                    let session = getCurrentSession()
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
						
						subAction.setValue(at, forKey: "at")
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
						
						subAction.setValue(at, forKey: "at")
						subAction.setValue(packageId, forKey: "packageId")
						subAction.setValue(itemId, forKey: "itemId")
						subAction.setValue(itemHandlerCount, forKey: "itemsToAdd")
						
						request = ItemRequest(with: [itemId!], sender: sender, action: subAction)
					}
                }
                else if(itemsHandlerId != nil){
					let subAction = NSMutableDictionary()
					var itemsToRequest: [String] = []
					let itemsToRequestCount = NSArray()
					
					
					for i in 0...((itemsHandlerId?.count)! - 1){
						guard let id = itemsHandlerId?[i] as? String else { continue }
						guard let count = itemsHandlerCount?[i] as? Int64 else { continue }
						if let item = allItems.first(where: {$0.id == id}){
							add(item, to: package!, count: count)
						}else{
							itemsToRequest.append(id)
							itemsToRequestCount.adding(count)
						}
					}
					
					if itemsToRequest.count > 0 {
					
						let at = NSNumber(value: ActionType.itemAddedToPackge.rawValue)
						
						subAction.setValue(at, forKey: "at")
						subAction.setValue(NSArray(array: itemsToRequest), forKey: "itemsToAdd")
						subAction.setValue(itemsToRequestCount, forKey: "itemsToAddCount")
						
						request = ItemRequest(with: itemsToRequest, sender: sender, action: subAction)
						
					}
				}
				
				
				if let req = request{
					let appDelegate = UIApplication.shared.delegate as! AppDelegate
					appDelegate.itemRequester.execute(request: req)
				}
				
                NotificationCenter.default.post(name: .addedItemToPackage, object: nil)
            }else if actionType == ActionType.disconnectPeer{
                if (action.value(forKey: "peer") as? String) == UIDevice.current.name{
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.pack.session.disconnect()
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
                    
                    NotificationCenter.default.post(name: .itemDeletedFromCharacter, object: action)
                    
                    CoreDataStack.saveContext()
                }
            }else if actionType == ActionType.sessionCreated{
                let sessionName = action.value(forKey: "sessionName") as? String
                let gameMaster = action.value(forKey: "gameMaster") as? String
                let gameMasterName = action.value(forKey: "gameMasterName") as? String
                let sessionId = action.value(forKey: "sessionId") as? String
                let sessionDevices = action.value(forKey: "sessionDevices") as? NSSet
                let context = CoreDataStack.managedObjectContext
                
                let session = NSEntityDescription.insertNewObject(forEntityName: String(describing: Session.self), into: context) as! Session
                
                session.name = sessionName
                session.gameMaster = gameMaster
                session.gameMasterName = gameMasterName
                session.id = sessionId
                session.devices = sessionDevices
                
                CoreDataStack.saveContext()
                
                let sessions: [Session] = Load.sessions()
                
                sessions.first(where: {$0.current == true})?.current = false
                session.current = true
                
                CoreDataStack.saveContext()
                
                NotificationCenter.default.post(name: .addedSession, object: session)
            }else if actionType == ActionType.sessionSwitched{
                NotificationCenter.default.post(name: .switchedSession, object: action)
                let sessionId = action.value(forKey: "sessionId") as! String
                
                let sessions: [Session] = Load.sessions()
                
                sessions.first(where: {$0.current == true})?.current = false
                
                sessions.first(where: {$0.id == sessionId})?.current = true
            }else if actionType == .sessionDeleted{
                let sessionId = action.value(forKey: "sessionId") as! String
                
                let context = CoreDataStack.managedObjectContext
                let sessions: [Session] = Load.sessions()

//                if action.value(forKey: "sessionIsActive") as? Bool == false{
//                    UserDefaults.standard.set(false, forKey: "sessionIsActive")
//                }
                
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
                
                let session = getCurrentSession()
                
                session.addToPackages(newPackage)
                
                CoreDataStack.saveContext()
                
                NotificationCenter.default.post(name: .createdPackage, object: nil)
            }else if actionType == .packageDeleted{
                if let packageId = action.value(forKey: "packageId") as? String{
                    if let package = Load.packages(with: packageId){
                        let session = getCurrentSession()
                        session.removeFromPackages(package)
                        CoreDataStack.saveContext()
                        NotificationCenter.default.post(name: .createdPackage, object: nil) //same as deletePackage
                    }
                }
            }else if actionType == .generatedRandomNumber{
                let number = action.value(forKey: "number") as! Int
                let message = "Wylosowano " + String(number)
                
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
				
				NotificationCenter.default.post(name: .addedNewAbility, object: (characterId,abilityId))
				
			}else if actionType == .valueOfAblilityChanged{
				guard let characterId = action.value(forKey: "characterId") as? String else {return}
				guard let abilityId = action.value(forKey: "abilityId") as? String else {return}
				guard let abilityValue = action.value(forKey: "abilityValue") as? Int16 else {return}
				
				guard let character = Load.character(with: characterId) else {return}
				
				guard let ability = character.abilities?.first(where: {($0 as! Ability).id == abilityId}) as? Ability else {return}
				ability.value = abilityValue

				CoreDataStack.saveContext()
				
				NotificationCenter.default.post(name: .valueOfAbilityChanged, object: (characterId,abilityId))
				
			}else if actionType == .removeAbility{
				guard let characterId = action.value(forKey: "characterId") as? String else {return}
				guard let abilityId = action.value(forKey: "abilityId") as? String else {return}
				
				guard let character = Load.character(with: characterId) else { return }
				
				guard let ability = character.abilities?.first(where: {($0 as! Ability).id == abilityId}) as? Ability else { return }
				
				let index = character.abilities?.sortedArray(using: [.sortAbilityByName]).index(where: {($0 as! Ability) == ability})
				
				let contex = CoreDataStack.managedObjectContext
				
				character.removeFromAbilities(ability)
				contex.delete(ability)
				
				CoreDataStack.saveContext()
				
				NotificationCenter.default.post(name: .removedAbility, object: (characterId ,index))
				
			}else if actionType == .removeCharacter{
				guard let characterId = action.value(forKey: "characterId") as? String else { return }
				
				guard let character = Load.character(with: characterId) else { return }
				
				let session = getCurrentSession()
				
				guard let index = (session.characters?.sortedArray(using: [.sortCharacterById]) as! [Character]).index(of: character) else { return }
				let indexPath = IndexPath(row: index, section: 0)
				
				let context = CoreDataStack.managedObjectContext
				
				context.delete(character)
				
				CoreDataStack.saveContext()
				
				NotificationCenter.default.post(name: .removedCharacter, object: indexPath)
				
			}else if actionType == .itemHandlerCountChanged{
				guard let characterId = action.value(forKey: "characterId") as? String else { return }
				guard let itemId = action.value(forKey: "itemId") as? String else { return }
				guard let itemCount = action.value(forKey: "itemCount") as? Int64 else { return }
				
				guard let character = Load.character(with: characterId) else { return }
				
				guard let handler = character.equipment?.first(where: {($0 as? ItemHandler)?.item?.id == itemId}) as? ItemHandler else { return }
				
				handler.count = itemCount
				
				CoreDataStack.saveContext()
				
				NotificationCenter.default.post(name: .itemHandlerCountChanged, object: (characterId,itemId))
			
			}else if actionType == .sessionReceived{
				guard let session = action.value(forKey: "session") as? NSDictionary else { return }
				
				
				guard let newSession =  unPackSession(from: session) else { return }
				
				if let setCurrent = action.value(forKey: "setCurrent") as? Bool{
					Load.sessions().first(where: {$0.current})?.current = false
					newSession.current = setCurrent
				}
				
				NotificationCenter.default.post(name: .sessionReceived, object: nil)
				
			}else if actionType == ActionType.itemsRequest{
				guard let itemsId = action.value(forKey: "itemsId") as? [String] else { return }
				let requestId = action.value(forKey: "id")
				
				let response = NSMutableDictionary()
				response.setValue(ActionType.itemsRequestResponse, forKey: "at")
				
				let itemsData = NSArray()
				
				for itemId in itemsId{
					
					guard let item = Load.item(with: itemId) else {
						continue
					}
					
					itemsData.adding(packItem(item))
				}
				
				response.setValue(itemsData, forKey: "itemsData")
				response.setValue(requestId, forKey: "requestId")
				
				let appDelegate = UIApplication.shared.delegate as! AppDelegate
				let pack = appDelegate.pack
				
				pack.send(response, to: sender)
				
			}else if actionType == ActionType.itemsRequestResponse{
				let itemsData = action.value(forKey: "itemsData") as! [NSDictionary]
				let requestId = action.value(forKey: "id")
				
				for itemData in itemsData{
					_ = unPackItem(from: itemData)
				}
				
				NotificationCenter.default.post(name: .recievedItemData, object: requestId)
			}
        }
    }
	
	func recievedLocaly(_ action: NSMutableDictionary){
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let localId = appDelegate.pack.myPeerID
		let packServ = appDelegate.pack
		self.recieved(action, from: localId, manager: packServ)
	}

    func lost(_ peer: MCPeerID) {
        let message = "Utracono połączenie z " + peer.displayName
        whisper(messege: message)
        UserDefaults.standard.set(false, forKey: "sessionIsActive")
    }
    
    func found(_ peer: MCPeerID) {
        DispatchQueue.main.async{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            var connectedDevices = appDelegate.pack.session.connectedPeers.map({$0.displayName})
            connectedDevices.append(UIDevice.current.name)
            
            let devices = NSSet(array: connectedDevices)
            
            let session = getCurrentSession()
            
            let sessionDevices = session.devices as? NSSet
            
            print(devices)
            print(sessionDevices as Any)
            if sessionDevices != nil && sessionDevices! == devices && devices.count > 0{

                
                UserDefaults.standard.set(true, forKey: "sessionIsActive")
            }else{
                let message = "Ponownie połączono z " + peer.displayName
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
