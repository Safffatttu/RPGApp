//
//  CharacterMoneyChanged.swift
//  RPGAapp
//
//  Created by Jakub on 06.09.2018.
//

import Foundation
import MultipeerConnectivity

struct CharacterMoneyChanged: Action {
	
	var actionType: ActionType = ActionType.characterMoneyChanged
	var data: ActionData{
		get{
			let data = ActionData(dictionary: [
				"characterId": characterId,
				"money"    : money,
				])
			return data
		}
	}
	
	var sender: MCPeerID?
	
	var characterId: String
	var money: Double
	
	var actionData: ActionData?
	
	init(actionData: ActionData, sender: MCPeerID){
		self.sender = sender
		
		self.characterId = actionData.value(forKey: "characterId") as! String
		self.money = actionData.value(forKey: "money") as! Double
		
		self.actionData = actionData
	}
	
	init(character: Character){
		self.characterId = character.id!
		self.money = character.money
	}
	
	
	func execute(){
		guard let character = Load.character(with: characterId) else { return }
		
		character.money = money
		
		CoreDataStack.saveContext()
		
		NotificationCenter.default.post(name: .reloadTeam, object: nil)
	}
}
