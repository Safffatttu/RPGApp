//
//  MapEntityMoved.swift
//  RPGAapp
//
//  Created by Jakub on 31.08.2018.
//

import Foundation
import MultipeerConnectivity

struct MapEntityMoved: Action {
	
	var actionType: ActionType = ActionType.mapEntityMoved
	var data: ActionData {
		get {
			let data = ActionData(dictionary: [
				"entityId": entityId,
				"posX"    : posX,
				"posY"    : posY
				])
			return data
		}
	}
	
	var sender: MCPeerID?
	
	var entityId: String
	var posX: Double
	var posY: Double
	
	var actionData: ActionData?
	
	init(actionData: ActionData, sender: MCPeerID) {
		self.sender = sender
		
		self.entityId = actionData.value(forKey: "entityId") as! String
		self.posX = actionData.value(forKey: "posX") as! Double
		self.posY = actionData.value(forKey: "posY") as! Double
		
		self.actionData = actionData
	}
	
	init(mapEntity: MapEntity) {
		self.entityId = mapEntity.id!
		self.posX = mapEntity.x
		self.posY = mapEntity.y
	}
	
	
	func execute() {
		guard let entity = Load.mapEntity(withId: entityId) else { return }
		
		entity.x = posX
		entity.y = posY
		
		CoreDataStack.saveContext()
		
		let newPos = CGPoint(x: posX, y: posY)
		
		NotificationCenter.default.post(name: .mapEntityMoved, object: (entity, newPos))
	}
}
