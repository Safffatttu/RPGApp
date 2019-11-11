//
//  ItemsRequest.swift
//  RPGAapp
//
//  Created by Jakub on 30.08.2018.
//

import Foundation
import MultipeerConnectivity

struct ItemsRequest: Action {
	
	var actionType: ActionType = ActionType.itemsRequest
	var data: ActionData {
		get {
			let data = ActionData(dictionary: [
				"itemsId": itemsId,
				"requestId": requestId
				])
			return data
		}
	}
	
	var sender: MCPeerID?
	
	var itemsId: [String]
	var requestId: String
	
	var actionData: ActionData?
	
	init(actionData: ActionData, sender: MCPeerID) {
		self.sender = sender
		
		self.itemsId = actionData.value(forKey: "itemsId") as! [String]
		self.requestId = actionData.value(forKey: "requestId") as! String
		
		self.actionData = actionData
	}
	
	init(itemsId: [String], requestId: String) {
		self.itemsId = itemsId
		self.requestId = requestId
	}
	
	init(itemsId: [String]) {
		self.itemsId = itemsId
		self.requestId = ""
	}
	
	func execute() {
		var itemsData: [NSDictionary] = []
		
		for itemId in itemsId {
			guard let item = Load.item(with: itemId) else { continue }
			let itemData = packItem(item)
			itemsData.append(itemData)
		}
		
		let action = ItemsRequestResponse(itemsData: itemsData, requestId: requestId)
		PackageService.pack.send(action: action, to: sender!)
	}
}
