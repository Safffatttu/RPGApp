//
//  ItemPackageAdded.swift
//  RPGAapp
//
//  Created by Jakub on 30.08.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct ItemPackageAdded: Action {
	var actionType: ActionType = ActionType.itemPackageAdded
	var data: ActionData{
		get{
			let data = ActionData(dictionary: [
				"packageId"    : packageId,
				"packageName"  : packageName,

				"itemsId"      : itemsId,
				"itemsCount"   : itemsCount
				])
			return data
		}
	}
	
	var sender: MCPeerID?
	
	var packageId: String
	var packageName: String
	
	var itemsId: [String]
	var itemsCount: [Int64]
	
	init(package: Package, itemsId: [String], itemsCount:  [Int64]){
		self.packageId = package.id!
		self.packageName = package.name!
		
		self.itemsId = itemsId
		self.itemsCount = itemsCount
	}
	
	init(actionData: ActionData, sender: MCPeerID) {
		self.sender = sender
		
		self.packageId = actionData.value(forKey: "packgeId") as! String
		self.packageName = actionData.value(forKey: "packgeName") as! String
		
		self.itemsId = actionData.value(forKey: "itemsId") as! [String]
		self.itemsCount = actionData.value(forKey: "itemsCount") as! [Int64]
	}
	
	func execute(){
		guard let package = Load.packages(with: self.packageId) else { return }
		
		let itemList = zip(self.itemsId, self.itemsCount)
		
		var requestList: [(String, Int64)] = []
		
		for itemData in itemList{
			guard let item = Load.item(with: itemData.0) else {
				requestList.append(itemData)
				continue
			}
			let count = itemData.1
			
			add(item, to: package, count: count)
		}
		
		if requestList.count != 0 {
			
			let requestAction = ItemPackageAdded(package: package, itemsId: requestList.map{$0.0}, itemsCount: requestList.map{$0.1})
			
			let data = requestAction.data
			data.setValue(self.actionType.rawValue, forKey: "action")
			
			let request = ItemRequest(with: requestList.map{$0.0}, sender: sender!, action: data)
			
			ItemRequester.rq.request(request)
		}
		
		NotificationCenter.default.post(name: .addedItemToPackage, object: nil)
	}
}
