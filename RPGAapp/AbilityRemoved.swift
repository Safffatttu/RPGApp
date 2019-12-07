//
//  AbilityRemoved.swift
//  RPGAapp
//
//  Created by Jakub on 30.08.2018.
//

import Foundation
import MultipeerConnectivity
import Whisper

struct AbilityRemoved: Action {

	var actionType: ActionType = .abilityRemoved
	var data: ActionData {
		let data = ActionData(dictionary: [
			"characterId": characterId,
			"abilityId": abilityId
			])
		return data
	}

	var sender: MCPeerID?

	let characterId: String
	let abilityId: String

	var actionData: ActionData?

	init(actionData: ActionData, sender: MCPeerID) {
		self.sender = sender

		self.characterId = actionData.value(forKey: "characterId") as! String
		self.abilityId = actionData.value(forKey: "abilityId") as! String

		self.actionData = actionData
	}

	init(characterId: String, abilityId: String) {
		self.characterId = characterId
		self.abilityId = abilityId
	}

	func execute() {
		guard let character = Load.character(with: characterId) else { return }
		guard let ability = character.abilities?.first(where: { ($0 as? Ability)?.id == abilityId }) as? Ability else { return }

		let contex = CoreDataStack.managedObjectContext

		character.removeFromAbilities(ability)
		contex.delete(ability)

		CoreDataStack.saveContext()

		NotificationCenter.default.post(name: .modifiedAbility, object: nil)
	}
}
