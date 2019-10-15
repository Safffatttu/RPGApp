//
//  SessionSwitched.swift
//  RPGAapp
//
//  Created by Jakub on 30.08.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct SessionSwitched: Action {
	
	var actionType: ActionType = ActionType.sessionSwitched
	var data: ActionData{
		get{
			let data = ActionData(dictionary: [
				"sessionId": sessionId
				])
			return data
		}
	}
	
	var sender: MCPeerID?
	var sessionId: String
	var actionData: ActionData?
	
	init(actionData: ActionData, sender: MCPeerID){
		self.sender = sender
		
		self.sessionId = actionData.value(forKey: "sessionId") as! String
		
		self.actionData = actionData
	}
	
	init(session: Session){
		self.sessionId = session.id!
	}
	
	func execute(){
		let sessions = Load.sessions()
		let currentSessions = sessions.filter{$0.current}
		
		for current in currentSessions{
			current.current = false
		}
		
		sessions.first(where: {$0.id == sessionId})?.current = true
		
		NotificationCenter.default.post(name: .switchedSession, object: nil)
		NotificationCenter.default.post(name: .reloadTeam, object: nil)
		NotificationCenter.default.post(name: .currencyChanged, object: nil)
	}
}
