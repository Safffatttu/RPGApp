//
//  MapTextureChanged.swift
//  RPGAapp
//
//  Created by Jakub on 06.09.2018.
//

import Foundation
import MultipeerConnectivity

struct MapTextureChanged: Action {
	
	var actionType: ActionType = ActionType.mapTextureChanged
	var data: ActionData{
		get{
			let data = ActionData(dictionary: [
				"mapId": mapId
				])
			return data
		}
	}
	
	var sender: MCPeerID?
	
	var mapId: String
	
	var actionData: ActionData?
	
	init(actionData: ActionData, sender: MCPeerID){
		self.sender = sender
		
		self.mapId = actionData.value(forKey: "mapId") as! String
		
		self.actionData = actionData
	}
	
	init(mapId: String){
		self.mapId = mapId
	}
	
	func execute(){
		let action = TextureRequest(id: mapId)
		PackageService.pack.send(action: action, to: sender!)
	}
}

