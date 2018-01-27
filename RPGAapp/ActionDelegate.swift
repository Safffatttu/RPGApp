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
    
    func recieved(_ action: NSMutableDictionary, manager: PackageService) {
        DispatchQueue.main.sync{
            let actionType = ActionType(rawValue: action.value(forKey: "action") as! Int)
            let sender = action.value(forKey: "sender") as? String
            print(action)
            
            if actionType == ActionType.applicationDidEnterBackground{
                let message = sender! + " wyszedł z aplikacji"
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
                
                if itemId != nil{
                    let item = allItems.first(where: {$0.id == itemId})
                        add(item!, to: package!, count: nil)
                }
                else if (itemHandlerId != nil){
                    let item = allItems.first(where: {$0.id == itemHandlerId})
                    add(item!, to: package!, count: itemHandlerCount)
                }
                else if(itemsHandlerId != nil){
                    for i in 0...((itemsHandlerId?.count)! - 1){
                        let id = itemsHandlerId?[i] as? String
                        let count = itemsHandlerCount?[i] as? Int64
                        let item = allItems.first(where: {$0.id == id})
                        add(item!, to: package!, count: count)
                    }
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
            }
        }
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
