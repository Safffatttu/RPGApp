//
//  addCharacter.swift
//  RPGAapp
//
//  Created by Jakub on 13.11.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class addCharacter: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var hpStepper: UIStepper!
    
    @IBOutlet weak var raceField: UITextField!
    
    @IBOutlet weak var profesionField: UITextField!
    
    @IBOutlet weak var hpField: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        self.preferredContentSize = CGSize(width: 300, height: 400)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(addCharacter(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissView(_:)))
    }
    
    func dismissView(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func addCharacter(_ sender: UIBarButtonItem){
        guard nameField.text != "" else {
            return
        }
        let newCharacter = NSEntityDescription.insertNewObject(forEntityName: String(describing: Character.self), into: CoreDataStack.managedObjectContext) as! Character
        newCharacter.setValue(nameField.text!, forKey: #keyPath(Character.name))
        newCharacter.setValue(hpStepper.value, forKey: #keyPath(Character.health))
        let id = nameField.text! + String((nameField.text! + UIDevice.current.name).hash)
        newCharacter.setValue(nameField.text! + id, forKey: #keyPath(Character.id))
        newCharacter.setValue(profesionField.text, forKey: #keyPath(Character.profession))
        
        let session = getCurrentSession()
        
        session.addToCharacters(newCharacter)
		
		let newMapEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: MapEntity.self), into: CoreDataStack.managedObjectContext) as! MapEntity
		
		newMapEntity.character = newCharacter
		newMapEntity.id = newCharacter.id
		newMapEntity.map = Load.currentMap(session: session)
		
        CoreDataStack.saveContext()
        
        NotificationCenter.default.post(name: .reloadTeam, object: nil)
        dismiss(animated: true, completion: nil)
        
        let action =  NSMutableDictionary()
        
        let actionType: NSNumber = NSNumber(value: ActionType.characterCreated.rawValue)
        action.setValue(actionType, forKey: "action")
        
        action.setValue(newCharacter.name, forKey: #keyPath(Character.name))
        action.setValue(newCharacter.health, forKey: #keyPath(Character.health))
        action.setValue(newCharacter.race, forKey: #keyPath(Character.race))
        action.setValue(newCharacter.id, forKey: #keyPath(Character.id))
        action.setValue(newCharacter.profession, forKey: #keyPath(Character.profession))
		
		action.setValue(newMapEntity.id, forKey: "mapEntityId")
		action.setValue(newMapEntity.x, forKey: "mapEntityPosX")
		action.setValue(newMapEntity.y, forKey: "mapEntityPosY")
		action.setValue(newMapEntity.map?.id, forKey: "mapId")
        
        PackageService.pack.send(action)
    }
}
