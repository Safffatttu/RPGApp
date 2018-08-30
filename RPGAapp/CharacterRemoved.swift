//
//  CharacterRemoved.swift
//  RPGAapp
//
//  Created by Jakub on 30.08.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import Whisper

struct CharacterRemoved: Action {
	
	var actionType: ActionType = ActionType.abilityRemoved
	var data: ActionData{
		get{
			let data = ActionData(dictionary: [
				"characterId": characterId
				])
			return data
		}
	}
	
	var sender: MCPeerID?
	
	let characterId: String
	
	var actionData: ActionData?
	
	init(actionData: ActionData, sender: MCPeerID){
		self.sender = sender
		
		self.characterId = actionData.value(forKey: "characterId") as! String
		
		self.actionData = actionData
	}
	
	init(characterId: String){
		self.characterId = characterId
	}
	
	func execute(){
		guard let character = Load.character(with: characterId) else { return }
		
		let contex = CoreDataStack.managedObjectContext
		
		contex.delete(character)
		
		CoreDataStack.saveContext()
		
		NotificationCenter.default.post(name: .reloadTeam, object: nil)
	}
}
