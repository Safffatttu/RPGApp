//
//  ItemCharacterChanged.swift
//  RPGAapp
//
//  Created by Jakub on 30.08.2018.
//

import Foundation
import MultipeerConnectivity

struct ItemCharacterChanged: Action {
	
	var actionType: ActionType = ActionType.itemCharacterChanged
	var data: ActionData{
		get{
			let data = ActionData(dictionary: [
				"characterId": characterId,
				"itemId"     : itemId,
				"itemCount"  : itemCount
				])
			return data
		}
	}
	
	var sender: MCPeerID?
	
	let characterId: String
	let itemId: String
	let itemCount: Int64
	
	var actionData: ActionData?
	
	init(actionData: ActionData, sender: MCPeerID){
		self.sender = sender
		
		self.characterId = actionData.value(forKey: "characterId") as! String
		self.itemId = actionData.value(forKey: "itemId") as! String
		self.itemCount = actionData.value(forKey: "itemCount") as! Int64
		
		self.actionData = actionData
	}
	
	init(characterId: String, itemId: String, itemCount: Int64){
		self.characterId = characterId
		self.itemId = itemId
		self.itemCount = itemCount
	}
	
	func execute(){
		guard let character = Load.character(with: characterId) else { return }
		
		guard let handler = character.equipment?
			.first(where: {($0 as? ItemHandler)?.item?.id == itemId}) as? ItemHandler else { return }
		
		handler.count = itemCount
		
		CoreDataStack.saveContext()
		
		NotificationCenter.default.post(name: .equipmentChanged, object: nil)
	}
}
