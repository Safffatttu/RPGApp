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
        do {
            try AnyAction(actionData: actionData, sender: sender).execute()
        } catch {
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
			} else {
				texture = NSEntityDescription.insertNewObject(forEntityName: String(describing: Texture.self), into: context) as! Texture
			}

			texture.data = data as NSData
			entity.texture = texture

			CoreDataStack.saveContext()

			NotificationCenter.default.post(name: .mapEntityTextureChanged, object: entity)
		} else if let map = Load.map(withId: withName) {

			let texture: Texture!

			if let existingTexture = map.background {
				texture = existingTexture
			} else {
				texture = NSEntityDescription.insertNewObject(forEntityName: String(describing: Texture.self), into: context) as! Texture
			}

			texture.data = data as NSData
			map.background = texture

			CoreDataStack.saveContext()

			NotificationCenter.default.post(name: .mapBackgroundChanged, object: nil)
		}
	
		do {
			try FileManager.default.removeItem(at: url)
		} catch {
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
