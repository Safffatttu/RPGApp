//
//  GeneratedRandomNumber.swift
//  RPGAapp
//
//  Created by Jakub on 30.08.2018.
//

import Foundation
import MultipeerConnectivity
import Whisper

struct GeneratedRandomNumber: Action {

	var actionType: ActionType = .generatedRandomNumber
	var data: ActionData {
		let data = ActionData(dictionary: [
			"number": number
			])
		return data
	}

	var sender: MCPeerID?

	var number: Int

	var actionData: ActionData?

	init(actionData: ActionData, sender: MCPeerID) {
		self.sender = sender

		self.number = actionData.value(forKey: "number") as! Int

		self.actionData = actionData
	}

	init(number: Int) {
		self.number = number
	}

	func execute() {
		let message = "\(NSLocalizedString("Drawn", comment: "")) \(number)"
		whisper(messege: message)
	}
}
