//
//  Action.swift
//  RPGAapp
//
//  Created by Jakub on 30.08.2018.
//

import Foundation
import MultipeerConnectivity

typealias ActionData = NSMutableDictionary

protocol Action {

	var actionType: ActionType { get }

	var data: ActionData { get }

	func execute()

	init(actionData: ActionData, sender: MCPeerID) throws

}

enum ActionType: Int {
	//Utility
	case disconnectPeer = 0
	case generatedRandomNumber

	//Item
	case itemCharacterAdded
	case itemCharacterDeleted
	case itemCharacterChanged

	case itemPackageAdded
	case itemPackageDeleted

	//Package
	case packageCreated
	case packageDeleted
	case packageSend

	//character
	case characterCreated
	case characterRemoved
	case characterMoneyChanged
	case characterHealthChanged

	// Map
	case mapEntityMoved
	case mapTextureChanged

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
	case textureRequest

	//Currency
	case currencyCreated

	//Visibility
	case visibilityCreated
	case visibilityRemoved
	case characterVisibilityChanged

	//Note
	case noteCreated
	case noteTextChanged
	case noteRemoved

}

struct AnyAction: Action {

    var base: Action

    init(_ base: Action) {
        self.base = base
    }
    
    var actionType: ActionType {
        base.actionType
    }

    var data: ActionData {
        base.data
    }

    func execute() {
        base.execute()
    }

    init(actionData: ActionData, sender: MCPeerID = MCPeerID(displayName: UIDevice.current.name)) throws {
        guard let actionNumber = actionData.value(forKey: "action") as? Int else { throw ParseError() }
        guard let actionType = ActionType(rawValue: actionNumber) else { throw ParseError() }
                
        if actionType == .itemCharacterAdded {
                base = ItemCharacterAdded(actionData: actionData, sender: sender)
            } else if actionType == .characterCreated {
                base = CharacterCreated(actionData: actionData, sender: sender)
            } else if actionType == .itemPackageAdded {
                base = ItemPackageAdded(actionData: actionData, sender: sender)
            } else if actionType == .disconnectPeer {
                base = DisconnectPeer(actionData: actionData, sender: sender)
            } else if actionType == .itemCharacterDeleted {
                base = ItemCharacterDeleted(actionData: actionData, sender: sender)
            } else if actionType == .sessionSwitched {
                base = SessionSwitched(actionData: actionData, sender: sender)
            } else if actionType == .sessionDeleted {
                base = SessionDeleted(actionData: actionData, sender: sender)
            } else if actionType == .packageCreated {
                base = PackageCreated(actionData: actionData, sender: sender)
            } else if actionType == .packageDeleted {
                base = PackageDeleted(actionData: actionData, sender: sender)
            } else if actionType == .generatedRandomNumber {
                base = GeneratedRandomNumber(actionData: actionData, sender: sender)
            } else if actionType == .abilityAdded {
                base = AbilityAdded(actionData: actionData, sender: sender)
            } else if actionType == .abilityValueChanged {
                base = AbilityValueChanged(actionData: actionData, sender: sender)
            } else if actionType == .abilityRemoved {
                base = AbilityRemoved(actionData: actionData, sender: sender)
            } else if actionType == .characterRemoved {
                base = CharacterRemoved(actionData: actionData, sender: sender)
            } else if actionType == .itemCharacterChanged {
                base = ItemCharacterChanged(actionData: actionData, sender: sender)
            } else if actionType == .sessionReceived {
                base = SessionReceived(actionData: actionData, sender: sender)
            } else if actionType == .itemsRequest {
                base = ItemsRequest(actionData: actionData, sender: sender)
            } else if actionType == .itemsRequestResponse {
                base = ItemsRequestResponse(actionData: actionData, sender: sender)
            } else if actionType == ActionType.mapEntityMoved {
                base = MapEntityMoved(actionData: actionData, sender: sender)
            } else if actionType == .itemListSync {
                base = ItemListSync(actionData: actionData, sender: sender)
            } else if actionType == .itemListRequested {
                base = ItemListRequested(actionData: actionData, sender: sender)
            } else if actionType == .itemListRecieved {
                base = ItemListRecieved(actionData: actionData, sender: sender)
            } else if actionType == .currencyCreated {
                base = CurrencyCreated(actionData: actionData, sender: sender)
            } else if actionType == .visibilityCreated {
                base = VisibilityCreated(actionData: actionData, sender: sender)
            } else if actionType == .characterVisibilityChanged {
                base = CharacterVisibilityChanged(actionData: actionData, sender: sender)
            } else if actionType == .itemPackageDeleted {
                base = ItemPackageDeleted(actionData: actionData, sender: sender)
            } else if actionType == .textureRequest {
                base = TextureRequest(actionData: actionData, sender: sender)
            } else if actionType == .visibilityRemoved {
                base = VisibilityRemoved(actionData: actionData, sender: sender)
            } else if actionType == .mapTextureChanged {
                base = MapTextureChanged(actionData: actionData, sender: sender)
            } else if actionType == .characterMoneyChanged {
                base = CharacterMoneyChanged(actionData: actionData, sender: sender)
            } else { // if actionType == .characterHealthChanged {
                base = CharacterHealthChanged(actionData: actionData, sender: sender)
        }
    }
}

struct ParseError: Error { }
