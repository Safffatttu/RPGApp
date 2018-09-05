//
//  CharacterCreated.swift
//  RPGAapp
//
//  Created by Jakub on 30.08.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import CoreData

struct CharacterCreated: Action {
	
	var actionType: ActionType = ActionType.characterCreated
	var data: ActionData{
		get{
			let data = ActionData(dictionary: [
				"name"         : name,
				"health"       : health,
				"race"         : race,
				"id"           : id,
				"profession"   : profession,
				"visibilityId" : visibilityId,
				
				"mapEntityId"  : mapEntityId,
				"mapEntityPosX": mapEntityPosX,
				"mapEntityPosY": mapEntityPosY,
				"mapId"        : mapId
				])
			return data
		}
	}
	
	var from: MCPeerID?
	
	var id: String?
	var name: String?
	var race: String?
	var health: Double?
	var profession: String?
	var visibilityId: String?
	
	var mapEntityId: String?
	var mapEntityPosX: Double?
	var mapEntityPosY: Double?
	var mapId: String?
	
	init(character: Character){
		id = character.id
		name = character.name
		race = character.race
		health = character.health
		profession = character.profession
		visibilityId = character.visibility?.id
		
		mapEntityId = character.mapRepresentation?.id
		mapEntityPosX = character.mapRepresentation?.x
		mapEntityPosY = character.mapRepresentation?.y
		mapId = character.mapRepresentation?.map?.id
		
	}
	
	init(actionData: ActionData, sender: MCPeerID) {
		from = sender
		
		id = actionData.value(forKey: "id") as? String
		name = actionData.value(forKey: "name") as? String
		race = actionData.value(forKey: "race") as? String
		health = actionData.value(forKey: "health") as? Double
		profession = actionData.value(forKey: "profession") as? String
		visibilityId = actionData.value(forKey: "visibilityId") as? String
		
		mapEntityId = actionData.value(forKey: "mapEntityId") as? String
		mapEntityPosX = actionData.value(forKey: "mapEntityPosX") as? Double
		mapEntityPosY = actionData.value(forKey: "mapEntityPosY") as? Double
		mapId = actionData.value(forKey: "mapId") as? String
	}
	
	func execute(){
		
		guard let characterId = id else { return }
		
		let session = Load.currentSession()
		
		let character: Character!
		
		if let exisitingCharacter = Load.character(with: characterId){
			character = exisitingCharacter
		}else {
			character = NSEntityDescription.insertNewObject(forEntityName: String(describing: Character.self), into: CoreDataStack.managedObjectContext) as! Character
			
			session.addToCharacters(character)
			
			character.visibility = Load.currentVisibility()
			
			let newMapEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: MapEntity.self), into: CoreDataStack.managedObjectContext) as! MapEntity
			
			newMapEntity.character = character
			newMapEntity.id = mapEntityId
			newMapEntity.x = mapEntityPosX!
			newMapEntity.y = mapEntityPosY!
			newMapEntity.map = Load.currentMap(session: session)
			
			let localizedNewCharacterString = NSLocalizedString("Added new character", comment: "")
			whisper(messege: localizedNewCharacterString)
		}
		
		character.name = name
		character.health = health ?? 0
		character.race = race
		character.id = id
		character.profession = profession
		
		if let visiblityId = visibilityId, let visiblity = Load.visibility(with: visiblityId){
				character.visibility = visiblity
			}
		
		CoreDataStack.saveContext()
		
		NotificationCenter.default.post(name: .reloadTeam, object: nil)
		
		let request = TextureRequest(mapId: "", entityId: (character.mapRepresentation?.id)!)
		PackageService.pack.send(action: request, to: from!)
	}
}
