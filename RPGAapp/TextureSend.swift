//
//  TextureSend.swift
//  RPGAapp
//
//  Created by Jakub on 31.08.2018.
//

import Foundation
import MultipeerConnectivity
import CoreData

struct TextureSend: Action {
	
	var actionType: ActionType = ActionType.textureSend
	var data: ActionData{
		get{
			let data = ActionData(dictionary: [
				"imageData": imageData,
				"mapId"    : mapId,
				"entityId" : entityId
				])
			return data
		}
	}
	
	var sender: MCPeerID?
	
	var imageData: NSData
	var mapId: String
	var entityId: String
	
	var actionData: ActionData?
	
	init(actionData: ActionData, sender: MCPeerID){
		self.sender = sender
		
		self.imageData = actionData.value(forKeyPath: "imageData") as! NSData
		self.mapId = actionData.value(forKeyPath: "mapId") as! String
		self.entityId = actionData.value(forKeyPath: "entityId") as! String
		
		self.actionData = actionData
	}
	
	init(imageData: NSData, mapId: String = "", entityId: String = ""){
		self.imageData = imageData
		self.mapId = mapId
		self.entityId = entityId
	}
	
	func execute(){
		let texture: Texture
		let contex = CoreDataStack.managedObjectContext
		
		if let map = Load.map(withId: mapId){
			
			if let exisitingTexture = map.background{
				texture = exisitingTexture
			}else{
				texture =  NSEntityDescription.insertNewObject(forEntityName: String(describing: Texture.self), into: contex) as! Texture
				map.background = texture
			}
			
			texture.data = imageData
			
			CoreDataStack.saveContext()
			
			NotificationCenter.default.post(name: .mapBackgroundChanged, object: nil)
			
		}else if let entity = Load.mapEntity(withId: entityId){
			
			if let exisitingTexture = entity.texture{
				texture = exisitingTexture
			}else{
				texture =  NSEntityDescription.insertNewObject(forEntityName: String(describing: Texture.self), into: contex) as! Texture
				entity.texture = texture
			}
			
			texture.data = imageData
			
			CoreDataStack.saveContext()
			
			NotificationCenter.default.post(name: .mapEntityTextureChanged, object: entity)
		}
		
	}
}
