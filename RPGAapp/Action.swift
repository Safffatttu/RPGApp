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

enum ActionType: Int {
	//Utility
	case applicationWillTerminate = 0
	case applicationDidEnterBackground
	case disconnectPeer
	case generatedRandomNumber
	
	//Item
	case itemCharacterAdded
	case itemCharacterDeleted
	case itemCharacterChanged
	
	case itemPackageAdded
	case itemDeletedPackage
	
	//Package
	case packageCreated
	case packageDeleted
	case packageSend
	
	//character
	case characterCreated
	case characterRemoved
	
	// Map
	case mapEntityMoved
	
	//Session
	case sessionCreated
	case sessionSwitched
	case sessionDeleted
	case sessionReceived
	
	//Ability
	case abilityAdded
	case abilityValueChanged
	case abilityRemoved
	
	//ItemData
	case itemsRequest
	case itemsRequestResponse
	case itemDataSend
	case itemListRequested
	case itemListRecieved
	case itemListSync

	//Textures
	case textureSend
	case textureRequest

	//Currency
	case currencyCreated
	
	//Visibility
	case visibilityCreated
	case characterVisibilityChanged
	
	
}
