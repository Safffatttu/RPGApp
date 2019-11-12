//
//  VisibilityRemoved.swift
//  RPGAapp
//
//  Created by Jakub on 02.09.2018.
//

import Foundation
import MultipeerConnectivity

struct VisibilityRemoved: Action {

	var actionType: ActionType = .visibilityRemoved
	var data: ActionData {
        let data = ActionData(dictionary: [
            "visibilityId": visibilityId
            ])
        return data
	}

	var sender: MCPeerID?

	var visibilityId: String

	var actionData: ActionData?

	init(actionData: ActionData, sender: MCPeerID) {
		self.sender = sender
	
		self.visibilityId = actionData.value(forKeyPath: "visibilityId") as! String
	
		self.actionData = actionData
	}

	init(visibilityId: String) {
		self.visibilityId = visibilityId
	}

	func execute() {
		guard let visibility = Load.visibility(with: visibilityId) else { return }
	
		let context = CoreDataStack.managedObjectContext
		context.delete(visibility)
	
		CoreDataStack.saveContext()
	
		NotificationCenter.default.post(name: .visibilityCreated, object: nil)
		NotificationCenter.default.post(name: .reloadTeam, object: nil)
	}
}
