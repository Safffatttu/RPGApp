//
//  AbilityValueChanged.swift
//  RPGAapp
//
//  Created by Jakub on 30.08.2018.
//

import Foundation
import MultipeerConnectivity
import CoreData

struct AbilityValueChanged: Action {
	
	var actionType: ActionType = ActionType.abilityValueChanged
	var data: ActionData {
		get {
			let data = ActionData(dictionary: [
				"characterId" : characterId,
				"abilityId"   : abilityId,
				"abilityValue": abilityValue
				])
			return data
		}
	}
	
	var sender: MCPeerID?
	
	var characterId:  String
	var abilityId:    String
	var abilityValue: Int16
	
	var actionData: ActionData?
	
	init(actionData: ActionData, sender: MCPeerID) {
		self.sender = sender
		
		self.characterId = actionData.value(forKey: "characterId") as! String
		self.abilityId = actionData.value(forKey: "abilityId") as! String
		self.abilityValue = actionData.value(forKey: "abilityValue") as! Int16
		
		self.actionData = actionData
	}
	
	init(ability: Ability) {
		self.characterId = (ability.character?.id)!
		self.abilityId = ability.id!
		self.abilityValue = ability.value
	}
	
	func execute() {
		guard let character = Load.character(with: characterId) else {return}
		guard let ability = character.abilities?.first(where: {($0 as! Ability).id == abilityId}) as? Ability else {return}
		
		ability.value = abilityValue
		
		CoreDataStack.saveContext()
		
		NotificationCenter.default.post(name: .valueOfAblitityChanged, object: abilityId)
	}
}
