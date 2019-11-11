//
//  PackageDeleted.swift
//  RPGAapp
//
//  Created by Jakub on 30.08.2018.
//

import Foundation
import MultipeerConnectivity

struct PackageDeleted: Action {
	
	var actionType: ActionType = ActionType.packageDeleted
	var data: ActionData{
		get{
			let data = ActionData(dictionary: [
				"packageId"  : packageId
				])
			return data
		}
	}
	
	var sender: MCPeerID?
	
	var packageId: String
	
	var actionData: ActionData?
	
	init(actionData: ActionData, sender: MCPeerID){
		self.sender = sender
		
		self.packageId = actionData.value(forKey: "packageId") as! String
		
		self.actionData = actionData
	}
	
	init(packageId: String){
		self.packageId = packageId
	}
	
	func execute(){
		guard let package = Load.packages(with: packageId) else { return }
		
		CoreDataStack.managedObjectContext.delete(package)
		CoreDataStack.saveContext()
		
		NotificationCenter.default.post(name: .createdPackage, object: nil)
	}
}
