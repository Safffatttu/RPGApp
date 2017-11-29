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

class ActionDelegate: NSObject, PackageServiceDelegate{
    
    func recieved(_ action: NSMutableDictionary, manager: PackageService) {
        DispatchQueue.main.async{
            let actionType = ActionType(rawValue: action.value(forKey: "action") as! Int)
            let sender = action.value(forKey: "sender") as? String
            print(action)
            
            if actionType == ActionType.applicationDidEnterBackground{
                let message = sender! + " wyszedł z aplikacji"
                self.showPopover(with: message)
            }else if actionType == ActionType.itemSend{
                var character: Character? = nil
                let characterId = action.value(forKey: "characterId") as? String
                var item: Item? = nil
                let itemId = action.value(forKey: "itemId") as? String
                let context = CoreDataStack.managedObjectContext
                
                guard characterId != nil && itemId != nil else {
                    return
                }
                
                let characterFetch: NSFetchRequest<Character> = Character.fetchRequest()
                let itemFetch: NSFetchRequest<Item> = Item.fetchRequest()
                
                do{
                    character = try context.fetch(characterFetch).first(where: {$0.id == characterId})
                }catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
                
                do{
                    item = try context.fetch(itemFetch).first(where: {$0.id == itemId})
                }catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
                
                guard item != nil && character != nil else {
                    return
                }
                
                addToEquipment(item: item!, toCharacter: character!)
                
                NotificationCenter.default.post(name: .itemAddedToCharacter, object: action)
                    
                CoreDataStack.saveContext()
            }else if actionType == ActionType.characterCreated{
                let newCharacter = NSEntityDescription.insertNewObject(forEntityName: String(describing: Character.self), into: CoreDataStack.managedObjectContext) as! Character
                
                newCharacter.name = action.value(forKey: #keyPath(Character.name)) as? String
                newCharacter.health = action.value(forKey: #keyPath(Character.health)) as! Double
                newCharacter.race = action.value(forKey: #keyPath(Character.race)) as? String
                newCharacter.id = action.value(forKey: #keyPath(Character.id)) as? String
                newCharacter.profession = action.value(forKey: #keyPath(Character.profession)) as? String
                
                CoreDataStack.saveContext()
                
                NotificationCenter.default.post(name: .reloadTeam, object: nil)
                self.showPopover(with: "Dodano nową postać")
            }else if actionType == ActionType.itemAddedToPackge{
                let itemId = action.value(forKey: "itemId") as? String
                let itemHandlerId = action.value(forKey: "itemToAdd") as? String
                let itemHandlerCount = action.value(forKey: "itemsToAdd") as? Int64
                let itemsHandlerId = action.value(forKey: "itemsToAdd") as? NSArray
                let itemsHandlerCount = action.value(forKey: "itemsToAddCount") as? NSArray
                let itemFetch: NSFetchRequest<Item> = Item.fetchRequest()
                var allItems: [Item] = []
                let context = CoreDataStack.managedObjectContext
                
                let packageName = action.value(forKey: "packageName") as! String
                let packageFetch: NSFetchRequest<Package> = Package.fetchRequest()
                var package: Package? = nil
                
                do{
                    package = try context.fetch(packageFetch).first(where: {$0.name == packageName})
                    allItems = try context.fetch(itemFetch)
                }
                catch{
                    print(error)
                }
                
                if package == nil{
                    package = NSEntityDescription.insertNewObject(forEntityName: String(describing: Package.self), into: context) as? Package
                    package?.name = packageName
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
                NotificationCenter.default.post(name: .reloadCharacterItems, object: nil)
            }else if actionType == ActionType.disconnectPeer{
                if (action.value(forKey: "peer") as? String) == UIDevice.current.name{
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.pack.session.disconnect()
                }
            }else if actionType == ActionType.itemDeletedFromCharacter{
                let itemId = action.value(forKey: "itemId") as? String
                let characterId = action.value(forKey: "characterId") as? String
                
                var item: Item? = nil
                var character: Character? = nil
                
                let context = CoreDataStack.managedObjectContext
                let itemFetch: NSFetchRequest<Item> = Item.fetchRequest()
                let characterFetch: NSFetchRequest<Character> = Character.fetchRequest()
                do{
                    item = try context.fetch(itemFetch).first(where: {$0.id == itemId})!
                    character = try context.fetch(characterFetch).first(where: {$0.id! == characterId!})!
                }catch{
                    print(error)
                }
                let equipment = character?.equipment?.allObjects as! [ItemHandler]
                
                character?.removeFromEquipment(equipment.first(where: {$0.item == item})!)

                NotificationCenter.default.post(name: .itemDeletedFromCharacter, object: action)
                
                CoreDataStack.saveContext()
            }else if actionType == ActionType.sessionCreated{
                let sessionName = action.value(forKey: "sessionName") as? String
                let gameMaster = action.value(forKey: "gameMaster") as? String
                let gameMasterName = action.value(forKey: "gameMasterName") as? String
                let sessionId = action.value(forKey: "sessionId") as? String
                let context = CoreDataStack.managedObjectContext
                
                let session = NSEntityDescription.insertNewObject(forEntityName: String(describing: Session.self), into: context) as! Session
                
                session.name = sessionName
                session.gameMaster = gameMaster
                session.gameMasterName = gameMasterName
                session.id = sessionId
                
                CoreDataStack.saveContext()
                
                var sessions: [Session] = []
                let sessionFetch: NSFetchRequest<Session> = Session.fetchRequest()
                
                do{
                    sessions = try context.fetch(sessionFetch)
                }catch{
                    print(error)
                }
                
                sessions.first(where: {$0.current == true})?.current = false
                session.current = true
                
                CoreDataStack.saveContext()
                
                NotificationCenter.default.post(name: .addedSession, object: session)
            }else if actionType == ActionType.sessionSwitched{
                NotificationCenter.default.post(name: .switchedSession, object: action)
                let sessionId = action.value(forKey: "sessionId") as! String
                
                let context = CoreDataStack.managedObjectContext
                var sessions: [Session] = []
                let sessionFetch: NSFetchRequest<Session> = Session.fetchRequest()
                
                do{
                    sessions = try context.fetch(sessionFetch)
                }catch{
                    print(error)
                }
                
                sessions.first(where: {$0.current == true})?.current = false
                
                sessions.first(where: {$0.id == sessionId})?.current = true
            }else if actionType == .sessionDeleted{
                let sessionId = action.value(forKey: "sessionId") as! String
                
                let context = CoreDataStack.managedObjectContext
                var sessions: [Session] = []
                let sessionFetch: NSFetchRequest<Session> = Session.fetchRequest()
                
                do{
                    sessions = try context.fetch(sessionFetch)
                }catch{
                    print(error)
                }

                if let session = sessions.first(where: {$0.id == sessionId}){
                    let index = sessions.index(of: session)
                    let indexPath = IndexPath(row: index! + 1, section: 1)
                    context.delete(session)
                    NotificationCenter.default.post(name: .sessionDeleted, object: indexPath)
                }
            }
        }
    }
    
    func lost(_ peer: MCPeerID) {
        let message = "Utracono połączenie z " + peer.displayName
        showPopover(with: message)
    }

    func connectedDevicesChanged(manager: PackageService, connectedDevices: [String]) {
        DispatchQueue.main.sync {
            NotificationCenter.default.post(name: .connectedDevicesChanged, object: nil)
        }
    }
    
    func showPopover(with message: String){
        DispatchQueue.main.async {
            let point = CGPoint(x: 15, y: 20)
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
            let frame = CGRect(x: view.frame.minX, y: view.frame.minY, width: view.frame.maxX, height: view.frame.maxY)
            let label = UILabel(frame: frame)
            label.text = message
            label.textAlignment = .center
            label.center = view.center
            view.addSubview(label)
            let popover = Popover()
            popover.arrowSize = .zero
            popover.show(view, point: point)
        }
    }
}
