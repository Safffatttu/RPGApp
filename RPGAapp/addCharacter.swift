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
        let newCharacter = NSEntityDescription.insertNewObject(forEntityName: String(describing: Character.self), into: CoreDataStack.managedObjectContext)
        newCharacter.setValue(nameField.text!, forKey: #keyPath(Character.name))
        newCharacter.setValue(hpStepper.value, forKey: #keyPath(Character.health))
        let id = nameField.text! + String((nameField.text! + UIDevice.current.name).hash)
        newCharacter.setValue(nameField.text! + id, forKey: #keyPath(Character.id))
        CoreDataStack.saveContext()
        
        NotificationCenter.default.post(name: .reloadTeam, object: nil)
        dismiss(animated: true, completion: nil)
    }
}
