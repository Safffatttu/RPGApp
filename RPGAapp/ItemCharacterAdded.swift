//
//  ItemCharacterAdded.swift
//  RPGAapp
//
//  Created by Jakub on 30.08.2018.
//

import Foundation
import MultipeerConnectivity

struct ItemCharacterAdded: Action {

	var actionType: ActionType = ActionType.itemCharacterAdded
	var data: ActionData {
        let data = ActionData(dictionary: [
                "itemsId": itemsId,
                "itemsCount": itemsCount,
                
                "characterId": characterId
            ])
        return data
	}

	var sender: MCPeerID?

	var itemsId: [String]
	var itemsCount: [Int64]

	var characterId: String

	var actionData: ActionData?

	init(actionData: ActionData, sender: MCPeerID) {
		self.sender = sender
	
		itemsId = actionData.value(forKey: "itemsId") as! [String]
		itemsCount = actionData.value(forKey: "itemsCount") as! [Int64]
	
		characterId = actionData.value(forKey: "characterId") as! String
	
		self.actionData = actionData
	}

	init(characterId: String, itemId: String) {
		self.itemsId = [itemId]
		self.itemsCount = [1]
		self.characterId = characterId
	}

	init(characterId: String, itemId: String, itemCount: Int64) {
		self.itemsId = [itemId]
		self.itemsCount = [itemCount]
		self.characterId = characterId
	}

	init(characterId: String, itemsId: [String], itemsCount: [Int64]) {
		self.itemsId = itemsId
		self.itemsCount = itemsCount
		self.characterId = characterId
	}

	func execute() {
		guard let character: Character = Load.character(with: characterId) else { return }
	
		let itemList = zip(self.itemsId, self.itemsCount)
	
		var requestList: [(String, Int64)] = []
	
		for itemData in itemList {
			guard let item = Load.item(with: itemData.0) else {
				requestList.append(itemData)
				continue
			}
			let count = itemData.1

			addToEquipment(item: item, to: character, count: count)
		}
	
		if requestList.count != 0 {

			let requestAction = ItemCharacterAdded(characterId: characterId, itemsId: requestList.map { $0.0 }, itemsCount: requestList.map { $0.1 })

			let data = requestAction.data
			data.setValue(requestAction.actionType.rawValue, forKey: "action")

			let request = ItemRequest(with: requestList.map {$0.0}, sender: sender!, action: data)

			ItemRequester.rq.request(request)
		}
	
		CoreDataStack.saveContext()
	
		NotificationCenter.default.post(name: .equipmentChanged, object: nil)
	}
}
