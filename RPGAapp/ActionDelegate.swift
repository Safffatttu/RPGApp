//
//  ActionDelegate.swift
//  RPGAapp
//
//  Created by Jakub on 12.11.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import CoreData
import Whisper

class ActionDelegate: PackageServiceDelegate{
	
	static var ad = ActionDelegate()	
	
    func received(_ actionData: ActionData, from sender: MCPeerID) {
		
		print(actionData)
		guard let actionNumber = actionData.value(forKey: "action") as? Int else { return }
		guard let actionType = ActionType(rawValue: actionNumber) else { return }
		
		if actionType == .itemCharacterAdded{
			let action = ItemCharacterAdded(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .characterCreated{
			let action = CharacterCreated(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .itemPackageAdded{
			let action = ItemPackageAdded(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .disconnectPeer{
			let action = DisconnectPeer(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .itemCharacterDeleted{
			let action = ItemCharacterDeleted(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .sessionSwitched{
			let action = SessionSwitched(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .sessionDeleted{
			let action = SessionDeleted(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .packageCreated{
			let action = PackageCreated(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .packageDeleted{
			let action = PackageDeleted(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .generatedRandomNumber{
			let action = GeneratedRandomNumber(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .abilityAdded{
			let action = AbilityAdded(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .abilityValueChanged{
			let action = AbilityValueChanged(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .abilityRemoved{
			let action = AbilityRemoved(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .characterRemoved{
			let action = CharacterRemoved(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .itemCharacterChanged{
			let action = ItemCharacterChanged(actionData: actionData, sender: sender)
			action.execute()
		
		}else if actionType == .sessionReceived{
			let action = SessionReceived(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .itemsRequest{
			let action = ItemsRequest(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .itemsRequestResponse{
			let action = ItemsRequestResponse(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == ActionType.mapEntityMoved{
			let action = MapEntityMoved(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .itemListSync{
			let action = ItemListSync(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .itemListRequested{
			let action = ItemListRequested(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .itemListRecieved{
			let action = ItemListRecieved(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .textureSend{
			let action = TextureSend(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .currencyCreated{
			let action = CurrencyCreated(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .visibilityCreated{
			let action = VisibilityCreated(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .characterVisibilityChanged{
			let action = CharacterVisibilityChanged(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .itemDeletedPackage{
			let action = ItemDeletedPackage(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .textureRequest{
			let action = TextureRequest(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .visibilityRemoved{
			let action = VisibilityRemoved(actionData: actionData, sender: sender)
			action.execute()
			
		}
    }
	
	func receiveLocally(_ actionData: NSMutableDictionary){
		
		let packServ = PackageService.pack
		let localId = packServ.myPeerID
		
		received(actionData, from: localId)
	}

    func lost(_ peer: MCPeerID) {
        let message = NSLocalizedString("Lost connection with", comment: "") + " " + peer.displayName
        whisper(messege: message)
    }
    
    func found(_ peer: MCPeerID) {
        DispatchQueue.main.async{
            let pack = PackageService.pack
            var connectedDevices = pack.session.connectedPeers.map({$0.displayName})
            connectedDevices.append(UIDevice.current.name)
            
            let devices = NSSet(array: connectedDevices)
            
            let session = Load.currentSession()
            
            let sessionDevices = session.devices as? NSSet
            
            print(devices)
            print(sessionDevices as Any)
            if sessionDevices != nil && sessionDevices! == devices && devices.count > 0{               
                UserDefaults.standard.set(true, forKey: "sessionIsActive")
            }else{
                let message = NSLocalizedString("Reconneced with", comment: "") + " " + peer.displayName
                whisper(messege: message)
            }
        }
    }
    
    func connectedDevicesChanged(manager: PackageService, connectedDevices: [String]) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .connectedDevicesChanged, object: nil)
        }
    }
}
