///Users/jakub/Dysk Google/Xcode/RPGAapp/RPGAapp
//  addCharacterModalViewController.swift
//  RPGAapp
//
//  Created by Jakub on 19.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit

class addCharacter: UIViewController {
    
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var hpStepper: UIStepper!
    
    @IBOutlet weak var raceField: UITextField!
    
    @IBOutlet weak var profesionField: UITextField!
    
    @IBOutlet weak var hpField: UILabel!
    
    @IBAction func stepperChanged(_ sender: UIStepper) {
        hpField.text = String(describing: Int(sender.value)) + "HP"
    }

    override func viewDidLoad() {
        self.preferredContentSize = CGSize(width: 300, height: 400)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(addCharacter(_:)))
        hpField.text = String(describing: Int(hpStepper.value)) + "HP"
    }
    
    
    
    func addCharacter(_ sender: UIBarButtonItem){
        let newCharacter = character(name: nameField.text!, health: Int(hpStepper.value), race: raceField.text, profesion: profesionField.text, abilites: [], items: [])
        team.append(newCharacter)
        NotificationCenter.default.post(name: .reloadTeam, object: nil)
        dismiss(animated: true, completion: nil)
        
    }
}
