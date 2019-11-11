//
//  ActionDelegate.swift
//  RPGAapp
//
//  Created by Jakub on 12.11.2017.
//

import Foundation
import MultipeerConnectivity
import CoreData
import Whisper

class ActionDelegate: PackageServiceDelegate {
	
	static var ad = ActionDelegate()	
	
    func received(_ actionData: ActionData, from sender: MCPeerID) {
		
		print(actionData)
		guard let actionNumber = actionData.value(forKey: "action") as? Int else { return }
		guard let actionType = ActionType(rawValue: actionNumber) else { return }
		
		if actionType == .itemCharacterAdded {
			let action = ItemCharacterAdded(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .characterCreated {
			let action = CharacterCreated(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .itemPackageAdded {
			let action = ItemPackageAdded(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .disconnectPeer {
			let action = DisconnectPeer(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .itemCharacterDeleted {
			let action = ItemCharacterDeleted(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .sessionSwitched {
			let action = SessionSwitched(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .sessionDeleted {
			let action = SessionDeleted(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .packageCreated {
			let action = PackageCreated(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .packageDeleted {
			let action = PackageDeleted(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .generatedRandomNumber {
			let action = GeneratedRandomNumber(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .abilityAdded {
			let action = AbilityAdded(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .abilityValueChanged {
			let action = AbilityValueChanged(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .abilityRemoved {
			let action = AbilityRemoved(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .characterRemoved {
			let action = CharacterRemoved(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .itemCharacterChanged {
			let action = ItemCharacterChanged(actionData: actionData, sender: sender)
			action.execute()
		
		}else if actionType == .sessionReceived {
			let action = SessionReceived(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .itemsRequest {
			let action = ItemsRequest(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .itemsRequestResponse {
			let action = ItemsRequestResponse(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == ActionType.mapEntityMoved {
			let action = MapEntityMoved(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .itemListSync {
			let action = ItemListSync(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .itemListRequested {
			let action = ItemListRequested(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .itemListRecieved {
			let action = ItemListRecieved(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .textureSend {
			let action = TextureSend(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .currencyCreated {
			let action = CurrencyCreated(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .visibilityCreated {
			let action = VisibilityCreated(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .characterVisibilityChanged {
			let action = CharacterVisibilityChanged(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .itemPackageDeleted {
			let action = ItemPackageDeleted(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .textureRequest {
			let action = TextureRequest(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .visibilityRemoved {
			let action = VisibilityRemoved(actionData: actionData, sender: sender)
			action.execute()
			
		}else if actionType == .mapTextureChanged {
			let action = MapTextureChanged(actionData: actionData, sender: sender)
			action.execute()
		}else if actionType == .characterMoneyChanged {
			let action = CharacterMoneyChanged(actionData: actionData, sender: sender)
			action.execute()
		}else if actionType == .characterHealthChanged {
			let action = CharacterHealthChanged(actionData: actionData, sender: sender)
			action.execute()
		}
    }
	
	func receiveLocally(_ actionData: NSMutableDictionary) {
		let packServ = PackageService.pack
		let localId = packServ.myPeerID
		
		received(actionData, from: localId)
	}
	
	func finishedReciveingResource(withName: String, from: MCPeerID, url: URL) {
		let data: Data
		
		do {
			data = try Data(contentsOf: url)
		} catch {
			print(error)
			return
		}
		
		let context = CoreDataStack.managedObjectContext
		
		if let entity = Load.mapEntity(withId: withName) {
			
			let texture: Texture!
			
			if let existingTexture = entity.texture {
				texture = existingTexture
			}else {
				texture = NSEntityDescription.insertNewObject(forEntityName: String(describing: Texture.self), into: context) as! Texture
			}
			
			texture.data = data as NSData
			entity.texture = texture
			
			CoreDataStack.saveContext()
			
			NotificationCenter.default.post(name: .mapEntityTextureChanged, object: entity)
		}else if let map = Load.map(withId: withName) {
			
			let texture: Texture!
			
			if let existingTexture = map.background {
				texture = existingTexture
			}else {
				texture = NSEntityDescription.insertNewObject(forEntityName: String(describing: Texture.self), into: context) as! Texture
			}
			
			texture.data = data as NSData
			map.background = texture
			
			CoreDataStack.saveContext()
			
			NotificationCenter.default.post(name: .mapBackgroundChanged, object: nil)
		}
		
		do {
			try FileManager.default.removeItem(at: url)
		}catch {
			print(error)
		}
	}

    func lost(_ peer: MCPeerID) {
		DispatchQueue.main.async {
			let message = NSLocalizedString("Lost connection with", comment: "") + " " + peer.displayName
			whisper(messege: message)
		}
    }
    
    func found(_ peer: MCPeerID) {
		DispatchQueue.main.async {
			let message = NSLocalizedString("Reconneced with", comment: "") + " " + peer.displayName
			whisper(messege: message)
        }
    }
    
    func connectedDevicesChanged(manager: PackageService, connectedDevices: [String]) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .connectedDevicesChanged, object: nil)
        }
    }
}
