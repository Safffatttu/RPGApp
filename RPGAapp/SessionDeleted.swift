//
//  SessionDeleted.swift
//  RPGAapp
//
//  Created by Jakub on 30.08.2018.
//

import Foundation
import MultipeerConnectivity

struct SessionDeleted: Action {

	var actionType: ActionType = .sessionDeleted
	var data: ActionData {
		let data = ActionData(dictionary: [
			"sessionId": sessionId
			])
		return data
	}

	var sender: MCPeerID?

	var sessionId: String

	var actionData: ActionData?

	init(actionData: ActionData, sender: MCPeerID) {
		self.sender = sender

		self.sessionId = actionData.value(forKey: "sessionId") as! String

		self.actionData = actionData
	}

	init(sessionId: String) {
		self.sessionId = sessionId
	}

	func execute() {
		guard UserDefaults.standard.bool(forKey: "syncSessionRemoval") else { return }
		guard let session = Load.session(with: sessionId) else { return }

		CoreDataStack.managedObjectContext.delete(session)
		CoreDataStack.saveContext()

		NotificationCenter.default.post(name: .sessionDeleted, object: nil)
		NotificationCenter.default.post(name: .reloadTeam, object: nil)
		NotificationCenter.default.post(name: .currencyChanged, object: nil)
	}
}
