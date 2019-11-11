//
//  CurrencyCreated.swift
//  RPGAapp
//
//  Created by Jakub on 31.08.2018.
//

import Foundation
import MultipeerConnectivity

struct CurrencyCreated: Action {

	var actionType: ActionType = ActionType.currencyCreated
	var data: ActionData {
        let data = ActionData(dictionary: [
            "currencyData": currencyData
            ])
        return data
	}

	var sender: MCPeerID?

	var currencyData: NSMutableDictionary

	var actionData: ActionData?

	init(actionData: ActionData, sender: MCPeerID) {
		self.sender = sender
	
		self.currencyData = actionData.value(forKey: "currencyData") as! NSMutableDictionary
	
		self.actionData = actionData
	}

	init(currency: Currency) {
		let data = packCurrency(currency)
		self.currencyData = data
	}

	func execute() {
		_ = unPackCurrency(currencyData: currencyData)
	
		NotificationCenter.default.post(name: .currencyCreated, object: nil)
	}
}
