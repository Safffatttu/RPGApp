//
//  ItemListSync.swift
//  RPGAapp
//
//  Created by Jakub on 31.08.2018.
//

import Foundation
import MultipeerConnectivity

struct ItemListSync: Action {

	var actionType: ActionType = .itemListSync
	var data: ActionData {
        let data = ActionData(dictionary: [:])
        return data
	}

	var sender: MCPeerID?

	var actionData: ActionData?

	init(actionData: ActionData, sender: MCPeerID) {
		self.sender = sender

		self.actionData = actionData
	}

	init() {
	}

	func execute() {
		let action = ItemListRequested()
		PackageService.pack.send(action: action)

	}
}
