//
//  ItemsRequestResponse.swift
//  RPGAapp
//
//  Created by Jakub on 30.08.2018.
//

import Foundation
import MultipeerConnectivity

struct ItemsRequestResponse: Action {
	
	var actionType: ActionType = ActionType.itemsRequestResponse
	var data: ActionData {
		get {
			let data = ActionData(dictionary: [
				"requestId": requestId,
				"itemsData": itemsData
				])
			return data
		}
	}
	
	var sender: MCPeerID?
	
	var itemsData: [NSDictionary]
	var requestId: String
	
	var actionData: ActionData?
	
	init(actionData: ActionData, sender: MCPeerID) {
		self.sender = sender
		
		self.itemsData = actionData.value(forKey: "itemsData") as! [NSDictionary]
		self.requestId = actionData.value(forKey: "requestId") as! String
		
		self.actionData = actionData
	}
	
	init(itemsData: [NSDictionary], requestId: String) {
		self.requestId = requestId
		self.itemsData = itemsData
	}
	
	func execute() {
		for itemData in itemsData {
			_ = unPackItem(from: itemData)
		}
		
		NotificationCenter.default.post(name: .receivedItemData, object: requestId)
	}
}
