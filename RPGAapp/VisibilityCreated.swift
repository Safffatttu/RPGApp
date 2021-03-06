//
//  VisibilityCreated.swift
//  RPGAapp
//
//  Created by Jakub on 31.08.2018.
//

import Foundation
import MultipeerConnectivity
import CoreData

struct VisibilityCreated: Action {

	var actionType: ActionType = .visibilityCreated
	var data: ActionData {
        let data = ActionData(dictionary: [
            "visibilityName": visibilityName,
            "visibilityId": visibilityId
            ])
        return data
	}

	var sender: MCPeerID?

	var visibilityName: String
	var visibilityId: String

	var actionData: ActionData?

	init(actionData: ActionData, sender: MCPeerID) {
		self.sender = sender
	
		self.visibilityName = actionData.value(forKeyPath: "visibilityName") as! String
		self.visibilityId = actionData.value(forKeyPath: "visibilityId") as! String
	
		self.actionData = actionData
	}

	init(visibility: Visibility) {
		self.visibilityName = visibility.name!
		self.visibilityId = visibility.id!
	}

	func execute() {
		let context = CoreDataStack.managedObjectContext
		let visibility = NSEntityDescription.insertNewObject(forEntityName: String(describing: Visibility.self), into: context) as! Visibility
	
		visibility.name = visibilityName
		visibility.id = visibilityId
		visibility.session = Load.currentSession()
	
		CoreDataStack.saveContext()
	
		NotificationCenter.default.post(name: .visibilityCreated, object: nil)
		NotificationCenter.default.post(name: .reloadTeam, object: nil)
	}
}
