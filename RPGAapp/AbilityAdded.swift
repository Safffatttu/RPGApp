//
//  AbilityAdded.swift
//  RPGAapp
//
//  Created by Jakub on 30.08.2018.
//

import Foundation
import MultipeerConnectivity
import CoreData

struct AbilityAdded: Action {

	var actionType: ActionType = .abilityAdded
	var data: ActionData {
		let data = ActionData(dictionary: [
			"characterId": characterId,
			"abilityName": abilityName,
			"abilityId": abilityId,
			"abilityValue": abilityValue
			])
		return data
	}

	var sender: MCPeerID?

	var characterId: String
	var abilityName: String
	var abilityId: String
	var abilityValue: Int16

	var actionData: ActionData?

	init(actionData: ActionData, sender: MCPeerID) {
		self.sender = sender

		self.characterId = actionData.value(forKey: "characterId") as! String
		self.abilityName = actionData.value(forKey: "abilityName") as! String
		self.abilityId = actionData.value(forKey: "abilityId") as! String
		self.abilityValue = actionData.value(forKey: "abilityValue") as! Int16

		self.actionData = actionData
	}

	init(ability: Ability) {
		self.characterId = (ability.character?.id)!
		self.abilityName = ability.name!
		self.abilityId = ability.id!
		self.abilityValue = ability.value
	}

	func execute() {
		guard let character = Load.character(with: characterId) else { return }

		let context = CoreDataStack.managedObjectContext
		let newAbility = NSEntityDescription.insertNewObject(forEntityName: String(describing: Ability.self), into: context) as! Ability

		newAbility.name = abilityName
		newAbility.id = abilityId
		newAbility.value = abilityValue
		newAbility.character = character

		CoreDataStack.saveContext()

		NotificationCenter.default.post(name: .modifiedAbility, object: nil)
	}
}
