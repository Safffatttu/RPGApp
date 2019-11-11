//
//  ItemPackageDeleted.swift
//  RPGAapp
//
//  Created by Jakub on 31.08.2018.
//

import Foundation
import MultipeerConnectivity

struct ItemPackageDeleted: Action {
	
	var actionType: ActionType = ActionType.itemPackageDeleted
	var data: ActionData {
		get {
			let data = ActionData(dictionary: [
				"packageId": packageId,
				"itemId"   : itemId
				])
			return data
		}
	}
	
	var sender: MCPeerID?
	
	var packageId: String
	var itemId: String
	
	var actionData: ActionData?
	
	init(actionData: ActionData, sender: MCPeerID) {
		self.sender = sender
		
		self.packageId = actionData.value(forKeyPath: "packageId") as! String
		self.itemId = actionData.value(forKeyPath: "itemId") as! String
		
		self.actionData = actionData
	}
	
	init(package: Package, itemId: String) {
		self.packageId = package.id!
		self.itemId = itemId
	}
	
	func execute() {
		guard let package = Load.packages(with: packageId) else { return }
		guard let itemHandlerToRemove = package.items?.first(where: {($0 as! ItemHandler ).item?.id == itemId}) as? ItemHandler else { return }
		
		package.removeFromItems(itemHandlerToRemove)
		
		let context = CoreDataStack.managedObjectContext
		context.delete(itemHandlerToRemove)
		
		CoreDataStack.saveContext()
		
		NotificationCenter.default.post(name: .addedItemToPackage, object: nil)
		
	}
}
