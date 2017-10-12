///Users/jakub/Dysk Google/Xcode/RPGAapp/RPGAapp
//  addCharacterModalViewController.swift
//  RPGAapp
//
//  Created by Jakub on 19.08.2017.
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
    
    @IBAction func stepperChanged(_ sender: UIStepper) {
        //hpField.text = String(describing: Int(sender.value)) + "HP"
    }

    override func viewDidLoad() {
        self.preferredContentSize = CGSize(width: 300, height: 400)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(addCharacter(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissView(_:)))
        //hpField.text = String(describing: Int(hpStepper.value)) + "HP"
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
        CoreDataStack.saveContext()
        
        NotificationCenter.default.post(name: .reloadTeam, object: nil)
        dismiss(animated: true, completion: nil)
    }
}
