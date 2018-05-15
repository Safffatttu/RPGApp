//
//  ActionTest.swift
//  RPGAapp
//
//  Created by Jakub on 15.05.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import XCTest
import UIKit
@testable import RPGAapp

class ActionTest: XCTestCase{
	
	let appDelegate = UIApplication.shared.delegate as! AppDelegate
	
	override func setUp() {
		super.setUp()
	}
	
	func testTest(){
		let action = createCharacter()
		appDelegate.actionDelegate.recievedLocaly(action)
	}
	
	
	func createCharacter(name: String = "asdd") -> NSMutableDictionary{
		let action = NSMutableDictionary()
		
		action.setValue(7, forKey: "action")
		
		let id = name + String((name + UIDevice.current.name).hash)
		
		action.setValue(name,forKey: "name")
		action.setValue(id, forKey: "id")
		
		action.setValue("", forKey: "profession")
		
		return action
	}
	
	
	func createAbility(name: String,characterId: String) -> NSMutableDictionary{
		let abilityId = String(strHash(name + characterId + String(describing: Date())))
		
		let action = NSMutableDictionary()
		let actionType = NSNumber(value: ActionType.addedAbilityToCharacter.rawValue)
		
		action.setValue(actionType, forKey: "action")
		
		action.setValue(name, forKey: "abilityName")
		action.setValue(abilityId, forKey: "abilityId")
		action.setValue(1, forKey: "abilityValue")
		action.setValue(characterId, forKey: "characterId")
		
		return action
	}
	
}
