//
//  CharacterHealthChanged.swift
//  RPGAapp
//
//  Created by Jakub on 04.10.2018.
//

import Foundation
import MultipeerConnectivity

struct CharacterHealthChanged: Action {

	var actionType: ActionType = ActionType.characterHealthChanged
	var data: ActionData {
        let data = ActionData(dictionary: [
            "characterId": characterId,
            "healthValue": healthValue
            ])
        return data
	}

	var sender: MCPeerID?

	var characterId: String
	var healthValue: Int16

	var actionData: ActionData?

	init(actionData: ActionData, sender: MCPeerID) {
		self.sender = sender
	
		self.characterId = actionData.value(forKey: "characterId") as! String
		self.healthValue = actionData.value(forKey: "healthValue") as! Int16
	
		self.actionData = actionData
	}

	init(character: Character) {
		self.characterId = character.id!
		self.healthValue = character.health
	}

	func execute() {
		guard let character = Load.character(with: characterId) else {return}
	
		character.health = healthValue
	
		CoreDataStack.saveContext()
	
		NotificationCenter.default.post(name: .reloadTeam, object: nil)
	}
}
