//
//  ActionTest.swift
//  RPGAapp
//
//  Created by Jakub on 15.05.2018.
//

import Foundation
import XCTest
import UIKit
import CoreData
@testable import RPGAapp

class ActionTest: XCTestCase{
	
	let ad = ActionDelegate.ad
	let pack = PackageService.pack
	override func setUp() {
		super.setUp()
		
	}
	
	func testRandomActions(){
		
		let expect = XCTestExpectation(description: "expect")
		
		DispatchQueue.global().async {
			while PackageService.pack.session.connectedPeers.count == 0 {
				sleep(1)
			}
			
			expect.fulfill()
		}
		 
		wait(for: [expect], timeout: 1000)
		
		
		DispatchQueue.main.async {
			for n in 0...1000 {
				print("test nr\(n)")
				
				guard let randAction = self.actions.random() else { continue }

				self.ad.receiveLocally(randAction)
//                self.pack.send(action: randAction)
				
				sleep(1)
			}
		}
	}
	
	func testLocalAction(){
		for n in 0...1000 {
			print("test nr\(n)")
			
			guard let randAction = self.actions.random() else { continue }
			
			self.ad.receiveLocally(randAction)
		}
	}
	
	let actions = [ ActionTest.createCharacterAction(),
//                    ActionTest.sendItemAction(),
					ActionTest.createPackgeAction(),
					ActionTest.deletePackageAction(),
					ActionTest.adddItemToPackageAction(),
					ActionTest.delteItemFromCharacter(),
					ActionTest.newSessionAction(),
					ActionTest.sessionSwitchedAction(),
					ActionTest.deleteSessionAction(),
					ActionTest.generatedRandomNumber(),
					ActionTest.addAbilityAction(),
					ActionTest.valueOfAbilityChangedAction()
		
	]
	
	public static func createCharacterAction() -> NSMutableDictionary{
		let action = NSMutableDictionary()
		
		action.setValue(NSNumber(value: ActionType.characterCreated.rawValue), forKey: "action")
		
		let name = String(myRand(10000))
		let id = name + String((name + UIDevice.current.name).hash)
		
		let profession = String(myRand(10000))
		let health = Double(myRand(1000)/222)
		let race = String(myRand(10000))
		
		let mapX = Double(myRand(1000)/222)
		let mapY = Double(myRand(1000)/222)
		
		action.setValue(name, forKey: #keyPath(RPGAapp.Character.name))
		action.setValue(health, forKey: #keyPath(RPGAapp.Character.health))
		action.setValue(race, forKey: #keyPath(RPGAapp.Character.race))
		action.setValue(id, forKey: #keyPath(RPGAapp.Character.id))
		action.setValue(profession, forKey: #keyPath(RPGAapp.Character.profession))

		action.setValue(id, forKey: "mapEntityId")
		action.setValue(mapX, forKey: "mapEntityPosX")
		action.setValue(mapY, forKey: "mapEntityPosY")
		
		return action
	}
	
//    public static func sendItemAction() -> NSMutableDictionary{
//        
//        let itemId = Load.items().random()?.id
//        let characterId = Load.characters().random()?.id
//        let count = Int64(myRand(100))
//        let action =  NSMutableDictionary()
//        
//        let actionType: NSNumber = NSNumber(value: ActionType.itemDataSend.rawValue)
//        action.setValue(actionType, forKey: "action")
//        
//
//        action.setValue(itemId, forKey: "itemId")
//        action.setValue(count, forKey: "itemCount")
//        
//        action.setValue(characterId, forKey: "characterId")
//        
//        return action
//    }
	
	public static func createPackgeAction() -> NSMutableDictionary{
		
		let name = "Paczka nr." + String(myRand(1000))
		let id = name + String(describing: Date())
		
		let action = NSMutableDictionary()
		let actionType = NSNumber(value: ActionType.packageCreated.rawValue)
		
		action.setValue(actionType, forKey: "action")
		action.setValue(name, forKey: "packageName")
		action.setValue(id, forKey: "packageId")
		
		return action
	}
	
	public static func deletePackageAction() -> NSMutableDictionary{
	
		guard let packageId = Load.packages().random()?.id else { return NSMutableDictionary() }
		
		let action = NSMutableDictionary()
		let actionType = NSNumber(value: ActionType.packageDeleted.rawValue)
		
		action.setValue(actionType, forKey: "action")
		action.setValue(packageId, forKey: "packageId")
		
		return action
	}
	
	public static func adddItemToPackageAction() -> NSMutableDictionary{
		
		guard let packageId = Load.packages().random()?.id  else { return NSMutableDictionary() }
		
		guard let itemId = Load.items().random()?.id else { return NSMutableDictionary() }
		
		let action = NSMutableDictionary()
		let actionType = NSNumber(value: ActionType.itemPackageAdded.rawValue)
		
		action.setValue(actionType, forKey: "action")
		action.setValue(packageId, forKey: "packageId")
		action.setValue(itemId, forKey: "itemId")
		
		return action
	}
	
	public static func delteItemFromCharacter() -> NSMutableDictionary{
	
		let character = Load.characters().random()
		guard let characterId = character?.id  else { return NSMutableDictionary() }
		guard let itemId = (character?.equipment?.allObjects.random() as? Item)?.id  else { return NSMutableDictionary() }
		
		let action = NSMutableDictionary()
		let actionType = NSNumber(value: ActionType.itemCharacterDeleted.rawValue)
		
		action.setValue(actionType, forKey: "action")
		
		action.setValue(itemId, forKey: "itemId")
		action.setValue(characterId, forKey: "characterId")
		
		return action
	}
	
	public static func newSessionAction() -> NSMutableDictionary{
		
		let context = CoreDataStack.managedObjectContext
		let session = NSEntityDescription.insertNewObject(forEntityName: String(describing: Session.self), into: context) as! Session
		
		session.name = String(myRand(1000))
		session.gameMaster = UIDevice.current.name
		session.current = true
		session.id = String(strHash(session.name! + session.gameMaster! + String(describing: Date())))
		
		let newMap = NSEntityDescription.insertNewObject(forEntityName: String(describing: Map.self), into: context) as! Map
		
		newMap.id = String(strHash(session.id!)) + String(describing: Date())
		newMap.current = true
		
		session.addToMaps(newMap)
		
		var devices = PackageService.pack.session.connectedPeers.map{$0.displayName}
		devices.append(UIDevice.current.name)
		
		CoreDataStack.saveContext()
		
		let action = NSMutableDictionary()
		let actionType = NSNumber(value: ActionType.sessionReceived.rawValue)
		
		action.setValue(actionType, forKey: "action")
		
		let sessionDictionary = packSessionForMessage(session)
		
		action.setValue(actionType, forKey: "action")
		action.setValue(sessionDictionary, forKey: "sessionData")
		action.setValue(session.current, forKey: "setCurrent")
		
		return action
	}
	
	public static func sessionSwitchedAction() -> NSMutableDictionary{
	
		guard let sessionId = Load.sessions().random()?.id else { return NSMutableDictionary() }
		
		let action = NSMutableDictionary()
		let actionType = NSNumber(value: ActionType.sessionSwitched.rawValue)
		
		action.setValue(actionType, forKey: "action")
		action.setValue(sessionId, forKey: "sessionId")
	
		return action
	}
	
	public static func deleteSessionAction() -> NSMutableDictionary{
		
		guard let sessionId = Load.sessions().random()?.id else { return NSMutableDictionary() }
		
		let action = NSMutableDictionary()
		let actionType = NSNumber(value: ActionType.sessionSwitched.rawValue)
		
		action.setValue(actionType, forKey: "action")
		action.setValue(sessionId, forKey: "sessionId")
		
		return action
	}
	
	public static func generatedRandomNumber() -> NSMutableDictionary{
		
		let number = myRand(1000)
		
		let action = NSMutableDictionary()
		let at = NSNumber(value: ActionType.generatedRandomNumber.rawValue)
		
		action.setValue(at, forKey: "action")
		action.setValue(number, forKey: "number")
		
		return action
	}
	
	public static func addAbilityAction() -> NSMutableDictionary{
		guard let characterId = Load.characters().random()?.id else { return NSMutableDictionary() }
		
		let name = String(myRand(10000))
		let abilityId = String(strHash(name + characterId + String(describing: Date())))
		
		let abilityValue = myRand(100)
		
		let action = NSMutableDictionary()
		let actionType = NSNumber(value: ActionType.abilityAdded.rawValue)
		
		action.setValue(actionType, forKey: "action")
		
		action.setValue(name, forKey: "abilityName")
		action.setValue(abilityId, forKey: "abilityId")
		
		action.setValue(abilityValue, forKey: "abilityValue")
		action.setValue(characterId, forKey: "characterId")
		
		return action
	}
	
	public static func valueOfAbilityChangedAction() -> NSMutableDictionary{
	
		guard let character = Load.characters().random() else { return NSMutableDictionary() }
		
		guard (character.abilities?.sortedArray(using: [.sortAbilityByName]).count)! > 0 else { return NSMutableDictionary()	}
		
		let characterId = character.id
		
		let ability = character.abilities?.sortedArray(using: [.sortAbilityByName]).random() as? Ability
		
		let abilityId = ability?.id
		let abilityValue = ability?.value
		
		let action = NSMutableDictionary()
		let actionType = NSNumber(value: ActionType.abilityValueChanged.rawValue)
		
		action.setValue(actionType, forKey: "action")
		
		action.setValue(abilityId, forKey: "abilityId")
		action.setValue(abilityValue, forKey: "abilityValue")
		action.setValue(characterId, forKey: "characterId")
		
		return action
	}
	
}
