//
//  ItemListRecieved.swift
//  RPGAapp
//
//  Created by Jakub on 31.08.2018.
//

import Foundation
import MultipeerConnectivity

struct ItemListRecieved: Action {

	var actionType: ActionType = .itemListRecieved
	var data: ActionData {
        let data = ActionData(dictionary: [
            "itemList": recievedItemList
            ])
        return data
	}

	var sender: MCPeerID?

	var recievedItemList: [String]

	var actionData: ActionData?

	init(actionData: ActionData, sender: MCPeerID) {
		self.sender = sender
	
		self.recievedItemList = actionData.value(forKeyPath: "itemList") as! [String]
	
		self.actionData = actionData
	}

	init(itemList: [String]) {
		self.recievedItemList = itemList
	}

	func execute() {
		let localItemList = Load.items().map {$0.id!}
	
		let requestList = recievedItemList.filter {itemId in
			!localItemList.contains(itemId)
		}
	
		let action = ItemsRequest(itemsId: requestList)
		PackageService.pack.send(action: action, to: sender!)
	
	}
}
