//
//  CharacterVisibilityChanged.swift
//  RPGAapp
//
//  Created by Jakub on 31.08.2018.
//

import Foundation
import MultipeerConnectivity
import CoreData

struct CharacterVisibilityChanged: Action {
	
	var actionType: ActionType = ActionType.characterVisibilityChanged
	var data: ActionData{
		get{
			let data = ActionData(dictionary: [
				"characterId" : characterId,
				"visibilityId": visibilityId
				])
			return data
		}
	}
	
	var sender: MCPeerID?
	
	var characterId: String
	var visibilityId: String
	
	var actionData: ActionData?
	
	init(actionData: ActionData, sender: MCPeerID){
		self.sender = sender
		
		self.characterId = actionData.value(forKeyPath: "characterId") as! String
		self.visibilityId = actionData.value(forKeyPath: "visibilityId") as! String
		
		self.actionData = actionData
	}
	
	init(character: Character, visibility: Visibility?){
		self.characterId = character.id!
		
		if let visibilityId = visibility?.id{
			self.visibilityId = visibilityId
		}else{
			self.visibilityId = ""
		}
	}
	
	func execute(){
		guard let character = Load.character(with: characterId) else { return }
		
		let visibility = Load.visibility(with: visibilityId)
		
		character.visibility = visibility
		
		CoreDataStack.saveContext()
		
		NotificationCenter.default.post(name: .reloadTeam, object: nil)

	}
}

