//
//  ItemListRequested.swift
//  RPGAapp
//
//  Created by Jakub on 31.08.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct ItemListRequested: Action {
	
	var actionType: ActionType = ActionType.itemListRequested
	var data: ActionData{
		get{
			let data = ActionData(dictionary: [: ])
			return data
		}
	}
	
	var sender: MCPeerID?
	
	var actionData: ActionData?
	
	init(actionData: ActionData, sender: MCPeerID){
		self.sender = sender
		
		self.actionData = actionData
	}
	
	init(){
		
	}
	
	func execute(){
		let itemList = Load.items().flatMap{$0.id}
		
		let action = ItemListRecieved(itemList: itemList)
		PackageService.pack.send(action: action, to: sender!)
	}
}
