//
//  ItemCharacterDeleted.swift
//  RPGAapp
//
//  Created by Jakub on 30.08.2018.
//


import Foundation
import MultipeerConnectivity

struct ItemCharacterDeleted: Action {

	var actionType: ActionType = .itemCharacterDeleted
	var data: ActionData {
		let data = ActionData(dictionary: [
			"characterId": characterId,
			"itemId": itemId
			])
		return data
	}

	var from: MCPeerID?

	var characterId: String
	var itemId: String

	init(characterId: String, itemId: String) {
		self.characterId = characterId
		self.itemId	= itemId
	}

	init(actionData: ActionData, sender: MCPeerID) {
		self.from = sender

		self.characterId = actionData.value(forKey: "characterId") as! String
		self.itemId = actionData.value(forKey: "itemId") as! String
	}

	func execute() {
		guard let character = Load.character(with: characterId) else { return }
		guard let item = Load.item(with: itemId) else { return }

		guard let handlerToDelete = character.equipment?
			.first(where: { ($0 as? ItemHandler)?.item == item }) as? ItemHandler else { return }

		let context = CoreDataStack.managedObjectContext

		context.delete(handlerToDelete)

		CoreDataStack.saveContext()

		NotificationCenter.default.post(name: .equipmentChanged, object: nil)
	}
}
