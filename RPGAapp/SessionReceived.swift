//
//  SessionRecieved.swift
//  RPGAapp
//
//  Created by Jakub on 30.08.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct SessionReceived: Action {
	
	var actionType: ActionType = ActionType.sessionReceived
	var data: ActionData{
		get{
			let data = ActionData(dictionary: [
				"sessionData": sessionData,
				"setCurrent" : setCurrent
				])
			return data
		}
	}
	
	var sender: MCPeerID?
	
	let sessionData: NSDictionary
	let setCurrent: Bool
	
	var actionData: ActionData?
	
	init(actionData: ActionData, sender: MCPeerID){
		self.sender = sender
		
		self.sessionData = actionData.value(forKey: "sessionData") as! NSDictionary
		self.setCurrent = actionData.value(forKey: "setCurrent") as! Bool
		
		self.actionData = actionData
	}
	
	init(session: Session, setCurrent: Bool = true){
		self.sessionData = packSessionForMessage(session)
		self.setCurrent = setCurrent
	}
	
	init(sessionData: NSDictionary, setCurrent: Bool = true){
		self.sessionData = sessionData
		self.setCurrent = setCurrent
	}
	
	func execute(){
		let sessionId = sessionData.value(forKey: "id") as! String
		
		if let session = Load.session(with: sessionId){
			let localizedTitle = NSLocalizedString("receive session with id of exising session", comment: "")
			let localizedMessage = NSLocalizedString("Do you want to replace it or keep local version?", comment: "")
			
			let alert = UIAlertController(title: localizedTitle, message: localizedMessage, preferredStyle: .alert)
			
			let localizedReplace = NSLocalizedString("Replace", comment: "")
			let alertReplace = UIAlertAction(title: localizedReplace, style: .default, handler: { _ in
				let contex = CoreDataStack.managedObjectContext
				
				contex.delete(session)
				
				self.createSession()
			})
			
			let localizedKeep = NSLocalizedString("Keep", comment: "")
			
			let alertKeep = UIAlertAction(title: localizedKeep, style: .default, handler: nil)
			
			alert.addAction(alertReplace)
			alert.addAction(alertKeep)
			
			guard let topViewController = UIApplication.topViewController() else { return }
			
			topViewController.present(alert, animated: true, completion: nil)
			
		}else{
			createSession()
		}
	}
	
	private func createSession(){
		guard let newSession = createSessionUsing(sessionData: self.sessionData, sender: self.sender!) else { return }
		
		let textureToRequest = getTextureId(from: sessionData)
		requestTexutures(id: textureToRequest, from: sender!)
		
		CoreDataStack.saveContext()
		
		NotificationCenter.default.post(name: .sessionReceived, object: nil)
		NotificationCenter.default.post(name: .reloadTeam, object: nil)
		
	}
	
	private func requestTexutures(id: [String], from: MCPeerID){
		for textureId in id{
			let action = TextureRequest(id: textureId)
			PackageService.pack.send(action: action, to: from)
		}
	}

}
