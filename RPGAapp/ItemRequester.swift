//
//  ItemRequester.swift
//  RPGAapp
//
//  Created by Jakub on 12.05.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import Dispatch
import UIKit
import MultipeerConnectivity

class ItemRequester {
	
	let requestQueue = ItemRequestQueue()

	static var rq = ItemRequester()
	
	init() {
		NotificationCenter.default.addObserver(self, selector: #selector(check(_:)), name: .receivedItemData, object: nil)
	}
	
	@objc func check(_ notfication: Notification){
		guard let requestId = notfication.object as? String else { return }
		
		guard let action = requestQueue.getActionWith(id: requestId) else { return }
		
		ActionDelegate.ad.receiveLocally(action.localAction)
	}
	
	func execute(request: ItemRequest) {
		requestQueue.add(request)
		
		let action = NSMutableDictionary()
		let at = NSNumber(value: ActionType.itemsRequest.rawValue)
		
		action.setValue(at, forKey: "action")
		action.setValue(request.itemsId, forKey: "itemsId")
		action.setValue(request.id, forKey: "id")
		
		PackageService.pack.send(action, to: request.from)
	}
	
	func request(_ request: ItemRequest){
		ItemRequester.rq.execute(request: request)
	}
	
}

class ItemRequestQueue {
	private var actionsToExecute: [ItemRequest] = []
	
	public func add(_ request: ItemRequest){
		actionsToExecute.append(request)
	}
	
	public func getActionWith(id: String) -> ItemRequest?{
		return actionsToExecute.drop(while: {$0.id == id}).first
	}
	
}

struct ItemRequest {
	let id: String
	var itemsId: [String]
	let from: MCPeerID
	var localAction = ActionData()
	
	init(with Ids: [String], sender: MCPeerID, action: ActionData) {
		itemsId = Ids
		from = sender
		localAction = action
		id = String(describing: Date())
	}
}

extension Notification.Name{
	static let receivedItemData = Notification.Name("receivedItemData")
}

