//
//  PackageCreated.swift
//  RPGAapp
//
//  Created by Jakub on 30.08.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import CoreData

struct PackageCreated: Action {
	
	var actionType: ActionType = ActionType.packageCreated
	var data: ActionData{
		get{
			let data = ActionData(dictionary: [
				"packageName": packageName,
				"packageId"  : packageId
				])
			return data
		}
	}
	
	var sender: MCPeerID?
	
	var packageName: String
	var packageId: String
	
	var actionData: ActionData?
	
	init(actionData: ActionData, sender: MCPeerID){
		self.sender = sender
		
		self.packageName = actionData.value(forKey: "packageName") as! String
		self.packageId = actionData.value(forKey: "packageId") as! String
		
		self.actionData = actionData
	}
	
	init(package: Package){
		self.packageId = package.id!
		self.packageName = package.name!		
	}
	
	func execute(){
		let context = CoreDataStack.managedObjectContext
		let newPackage = NSEntityDescription.insertNewObject(forEntityName: String(describing: Package.self), into: context) as! Package
		
		newPackage.name = packageName
		newPackage.id = packageId
		
		newPackage.visibility = Load.currentVisibility()
		
		let session = Load.currentSession()
		
		session.addToPackages(newPackage)
		
		CoreDataStack.saveContext()
		
		NotificationCenter.default.post(name: .createdPackage, object: nil)
	}
}

