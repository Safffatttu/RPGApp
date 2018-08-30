//
//  Action.swift
//  RPGAapp
//
//  Created by Jakub on 30.08.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation

typealias ActionData = NSMutableDictionary

protocol Action{
	
	var actionType: ActionType { get }
	
	var dictionary: ActionData { get }
	
	init(actionData: ActionData)
	
}
