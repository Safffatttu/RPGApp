//
//  TextureRequest.swift
//  RPGAapp
//
//  Created by Jakub on 31.08.2018.
//

import Foundation
import MultipeerConnectivity
import CoreData

struct TextureRequest: Action {
	
	var actionType: ActionType = ActionType.textureRequest
	var data: ActionData{
		get{
			let data = ActionData(dictionary: [
				"id"    : id,
				])
			return data
		}
	}
	
	var sender: MCPeerID?
	
	var id: String
	
	var actionData: ActionData?
	
	init(actionData: ActionData, sender: MCPeerID){
		self.sender = sender
		
		self.id = actionData.value(forKeyPath: "id") as! String
		
		self.actionData = actionData
	}
	
	init(id: String){
		self.id = id
	}
	
	func execute(){
		var imageData: NSData?
		
		if let texture = Load.texture(with: id) {
			imageData = texture.data
		}else if let data = Load.map(withId: id)?.background?.data{
			imageData = data
		}
		
		guard let data = imageData else { return }		

		var path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
		path.appendPathComponent(id)
		path = path.appendingPathExtension("texture")

		data.write(to: path, atomically: true)
		
		PackageService.pack.sendResourceAt(url: path, with: id, to: sender!, completionHandler: { e -> Void in
			do{
				try FileManager.default.removeItem(at: path)
			}catch{
				print(error)
			}
		})
	}
}
