//
//  ActionGenerator.swift
//  ActionGenerators
//
//  Created by Jakub Berkop on 01/02/2020.
//  Copyright © 2020 Jakub. All rights reserved.
//

import XCTest
import CoreData

@testable import RPGAapp

class ActionGenerator: XCTestCase {
    
    public static let actions = [ ActionGenerator.createCharacterAction,
                    ActionGenerator.createPackgeAction,
                    ActionGenerator.deletePackageAction,
                    ActionGenerator.adddItemToPackageAction,
                    ActionGenerator.addItemToCharacter,
                    ActionGenerator.delteItemFromCharacter,
                    ActionGenerator.newSessionAction,
                    ActionGenerator.sessionSwitchedAction,
                    ActionGenerator.deleteSessionAction,
                    ActionGenerator.generatedRandomNumber,
                    ActionGenerator.addAbilityAction,
                    ActionGenerator.valueOfAbilityChangedAction
    ]

    public static func createCharacterAction() -> ActionData {
        let action = NSMutableDictionary()

        action.setValue(NSNumber(value: ActionType.characterCreated.rawValue), forKey: "action")

        let name = String(myRand(10000))
        let id = name + String((name + UIDevice.current.name).hash)

        let profession = String(myRand(10000))
        let health = Double(myRand(1000) / 222)
        let race = String(myRand(10000))

        let mapX = Double(myRand(1000) / 222)
        let mapY = Double(myRand(1000) / 222)

        action.setValue(name, forKey: #keyPath(RPGAapp.Character.name))
        action.setValue(health, forKey: #keyPath(RPGAapp.Character.health))
        action.setValue(race, forKey: #keyPath(RPGAapp.Character.race))
        action.setValue(id, forKey: #keyPath(RPGAapp.Character.id))
        action.setValue(profession, forKey: #keyPath(RPGAapp.Character.profession))

        action.setValue(id, forKey: "mapEntityId")
        action.setValue(mapX, forKey: "mapEntityPosX")
        action.setValue(mapY, forKey: "mapEntityPosY")

        return action
    }

    public static func createPackgeAction() -> NSMutableDictionary {

        let name = "Paczka nr." + String(myRand(1000))
        let id = name + String(describing: Date())

        let action = NSMutableDictionary()
        let actionType = NSNumber(value: ActionType.packageCreated.rawValue)

        action.setValue(actionType, forKey: "action")
        action.setValue(name, forKey: "packageName")
        action.setValue(id, forKey: "packageId")

        return action
    }

    public static func deletePackageAction() -> NSMutableDictionary {
        var packageId: String?

        let loadPackage = DispatchWorkItem(block: {
            let id = Load.packages().randomElement()?.id
            if let id = id {
                packageId = id
            }
        })

        DispatchQueue.main.async(execute: loadPackage)
        loadPackage.wait()

        guard packageId != nil else { return NSMutableDictionary() }

        let action = NSMutableDictionary()
        let actionType = NSNumber(value: ActionType.packageDeleted.rawValue)

        action.setValue(actionType, forKey: "action")
        action.setValue(packageId, forKey: "packageId")

        return action
    }

    public static func adddItemToPackageAction() -> NSMutableDictionary {
        var packageId: String?
        var packageName: String?
        var itemIds: [String] = []

        let loadPackage = DispatchWorkItem(block: {
            packageId = Load.packages().randomElement()?.id
            packageName = Load.packages().randomElement()?.name
            itemIds = Load.items().compactMap { $0.id }
        })

        DispatchQueue.main.async(execute: loadPackage)
        loadPackage.wait()

        guard packageId != nil else { return NSMutableDictionary() }
        guard packageName != nil else { return NSMutableDictionary() }

        let numberOfItems = Int(arc4random_uniform(100))

        let itemsId = NSMutableArray()
        let itemsCount = NSMutableArray()


        for _ in 0...numberOfItems {
            guard let itemId = itemIds.randomElement() else { continue }
            let itemCount = Int(arc4random_uniform(100))
            itemsId.add(itemId)
            itemsCount.add(itemCount)
        }

        let action = NSMutableDictionary()
        let actionType = NSNumber(value: ActionType.itemPackageAdded.rawValue)

        action.setValue(actionType, forKey: "action")
        action.setValue(packageId, forKey: "packageId")
        action.setValue(packageName, forKey: "packageName")
        action.setValue(itemsId, forKey: "itemsId")
        action.setValue(itemsCount, forKey: "itemsCount")

        return action
    }

    public static func delteItemFromCharacter() -> NSMutableDictionary {
        var characterId: String?
        var itemId: String?

        let loadCharacter = DispatchWorkItem(block: {
            let character = Load.characters().randomElement()
            characterId = character?.id
            itemId = (character?.equipment?.allObjects.randomElement() as? Item)?.id
        })

        DispatchQueue.main.async(execute: loadCharacter)

        loadCharacter.wait()

        guard characterId != nil else { return NSMutableDictionary() }
        guard itemId != nil else { return NSMutableDictionary() }

        let action = NSMutableDictionary()
        let actionType = NSNumber(value: ActionType.itemCharacterDeleted.rawValue)

        action.setValue(actionType, forKey: "action")

        action.setValue(itemId, forKey: "itemId")
        action.setValue(characterId, forKey: "characterId")

        return action
    }

    public static func newSessionAction() -> NSMutableDictionary {
        let action = NSMutableDictionary()
        let actionType = NSNumber(value: ActionType.sessionReceived.rawValue)

        action.setValue(actionType, forKey: "action")

        let dictionary = NSMutableDictionary()
        let name = String(myRand(1000))
        dictionary.setValue(name, forKey: "name")
        let gameMaster = UIDevice.current.name
        dictionary.setValue(gameMaster, forKey: "gameMaster")
        let id = String(strHash(name + gameMaster + String(describing: Date())))
        dictionary.setValue(id, forKey: "id")


        dictionary.setValue(true, forKey: "current")

        let charactersToSend = NSMutableArray()
        dictionary.setValue(charactersToSend, forKey: "characters")
        let packages = NSMutableArray()
        dictionary.setValue(packages, forKey: "packages")
        let maps = NSMutableArray()
        let mapDict = NSMutableDictionary()
        mapDict.setValue(String(strHash(id)) + String(describing: Date()), forKey: "id")
        mapDict.setValue(0.0, forKey: "posX")
        mapDict.setValue(0.0, forKey: "posY")
        mapDict.setValue(true, forKey: "current")
        let mapEntities = NSMutableArray()
        mapDict.setValue(mapEntities, forKey: "mapEntities")
        mapDict.setValue(false, forKey: "hasBackground")

        maps.add(mapDict)

        dictionary.setValue(maps, forKey: "maps")


        let visibilties = NSMutableArray()
        dictionary.setValue(visibilties, forKey: "visibilties")
        let notes = NSMutableArray()
        dictionary.setValue(notes, forKey: "notes")

        let sessionDictionary = dictionary
        action.setValue(actionType, forKey: "action")
        action.setValue(sessionDictionary, forKey: "sessionData")
        action.setValue(true, forKey: "setCurrent")

        return action
    }

    public static func sessionSwitchedAction() -> NSMutableDictionary {
        var sessionId: String?

        let loadSessionId = DispatchWorkItem(block: {
            sessionId = Load.sessions().randomElement()?.id
        })

        DispatchQueue.main.async(execute: loadSessionId)
        loadSessionId.wait()

        guard sessionId != nil else { return NSMutableDictionary() }

        let action = NSMutableDictionary()
        let actionType = NSNumber(value: ActionType.sessionSwitched.rawValue)

        action.setValue(actionType, forKey: "action")
        action.setValue(sessionId, forKey: "sessionId")

        return action
    }

    public static func deleteSessionAction() -> NSMutableDictionary {
        var sessionId: String?

        let loadSessionId = DispatchWorkItem(block: {
            sessionId = Load.sessions().randomElement()?.id
        })

        DispatchQueue.main.async(execute: loadSessionId)
        loadSessionId.wait()

        guard sessionId != nil else { return NSMutableDictionary() }

        let action = NSMutableDictionary()
        let actionType = NSNumber(value: ActionType.sessionSwitched.rawValue)

        action.setValue(actionType, forKey: "action")
        action.setValue(sessionId, forKey: "sessionId")

        return action
    }

    public static func generatedRandomNumber() -> NSMutableDictionary {

        let number = myRand(1000)

        let action = NSMutableDictionary()
        let at = NSNumber(value: ActionType.generatedRandomNumber.rawValue)

        action.setValue(at, forKey: "action")
        action.setValue(number, forKey: "number")

        return action
    }

    public static func addAbilityAction() -> NSMutableDictionary {
        var characterId: String?

        let loadCharacter = DispatchWorkItem(block: {
            characterId = Load.characters().randomElement()?.id
        })

        DispatchQueue.main.async(execute: loadCharacter)
        loadCharacter.wait()

        guard characterId != nil else { return NSMutableDictionary() }

        let name = String(myRand(10000))
        let abilityId = String(strHash(name + characterId! + String(describing: Date())))

        let abilityValue = myRand(100)

        let action = NSMutableDictionary()
        let actionType = NSNumber(value: ActionType.abilityAdded.rawValue)

        action.setValue(actionType, forKey: "action")

        action.setValue(name, forKey: "abilityName")
        action.setValue(abilityId, forKey: "abilityId")

        action.setValue(abilityValue, forKey: "abilityValue")
        action.setValue(characterId, forKey: "characterId")

        return action
    }

    public static func valueOfAbilityChangedAction() -> NSMutableDictionary {
        var characterId: String?
        var abilityId: String?
        var abilityValue: Int16?

        let loadCharacter = DispatchWorkItem(block: {
            let character = Load.characters().randomElement()
            characterId = character?.id
            let ability = character?.abilities?.sortedArray(using: [.sortAbilityByName]).randomElement() as? Ability
            abilityId = ability?.id
            abilityValue = ability?.value
        })

        DispatchQueue.main.async(execute: loadCharacter)
        loadCharacter.wait()

        guard characterId != nil else { return NSMutableDictionary() }

        guard abilityId != nil else { return NSMutableDictionary() }
        guard abilityValue != nil else { return NSMutableDictionary() }

        let action = NSMutableDictionary()
        let actionType = NSNumber(value: ActionType.abilityValueChanged.rawValue)

        action.setValue(actionType, forKey: "action")

        action.setValue(abilityId, forKey: "abilityId")
        action.setValue(abilityValue, forKey: "abilityValue")
        action.setValue(characterId, forKey: "characterId")

        return action
    }

    public static func addItemToCharacter() -> NSMutableDictionary {
        var characterId: String?
        var itemIds: [String] = []
        let loadCharacter = DispatchWorkItem(block: {
            characterId = Load.characters().randomElement()?.id
            itemIds = Load.items().compactMap({ $0.id })
        })

        DispatchQueue.main.async(execute: loadCharacter)
        loadCharacter.wait()

        guard characterId != nil else { return NSMutableDictionary() }

        let action = NSMutableDictionary()
        let actionType = NSNumber(value: ActionType.itemCharacterAdded.rawValue)

        action.setValue(actionType, forKey: "action")

        let itemsId = NSMutableArray()
        let itemsCount = NSMutableArray()

        let numberOfItems = Int(arc4random_uniform(100))

        for _ in 0...numberOfItems {
            guard let itemId = itemIds.randomElement() else { continue }
            let itemCount = Int(arc4random_uniform(100))
            itemsId.add(itemId)
            itemsCount.add(itemCount)
        }

        action.setValue(actionType, forKey: "action")
        action.setValue(characterId, forKey: "characterId")

        action.setValue(itemsId, forKey: "itemsId")
        action.setValue(itemsCount, forKey: "itemsCount")

        return action
    }
}
