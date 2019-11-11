//
//  DisconnectPeer.swift
//  RPGAapp
//
//  Created by Jakub on 31.08.2018.
//

import Foundation
import MultipeerConnectivity

struct DisconnectPeer: Action {

	var actionType: ActionType = ActionType.disconnectPeer
	var data: ActionData {
		let data = ActionData(dictionary: [
			"peer": peer
			])
		return data
	}

	var sender: MCPeerID?

	var peer: String

	var actionData: ActionData?

	init(actionData: ActionData, sender: MCPeerID) {
		self.sender = sender
	
		self.peer = actionData.value(forKey: "peer") as! String
	
		self.actionData = actionData
	}

	init(peer: String) {
		self.peer = peer
	}

	func execute() {
		if peer == UIDevice.current.name {
			PackageService.pack.session.disconnect()
		}
	}
}
