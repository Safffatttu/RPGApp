//
//  RandomNumberGenerator.swift
//  RPGAapp
//
//  Created by Jakub on 07.12.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import UIKit

class RandomNumberGenerator: UITableViewController, StepperCellDelegate {
	
	let draw = [4,6,10,12,20,100]
	let models = DiceModel.allModels
	
	var numOfDices = { () -> Int in 
		let a = UserDefaults.standard.integer(forKey: "numberOfDices")
		if a < 1 {
			UserDefaults.standard.set(1, forKey: "numberOfDices")
			return 1
		}else{
			return a
		}
	}()
	
	func valueChaged(_ sender: UIStepper) {
		numOfDices = Int(sender.value)
		UserDefaults.standard.set(numOfDices, forKey: "numberOfDices")
		let text = NSLocalizedString("Number Of Dices", comment: "") + ": " + String(numOfDices)
		tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.textLabel?.text = text
	}
	
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0{
			return 1
		}
		if section == 1{
			return draw.count
		}else{
			return models.count
		}
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0{
			let cell = tableView.dequeueReusableCell(withIdentifier: "stepperCell") as! StepperCell
			cell.delegate = self
			cell.stepper.value = Double(numOfDices)
			cell.textLabel?.text = NSLocalizedString("Number Of Dices", comment: "") + ": " + String(numOfDices)
			return cell
		}
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

		if indexPath.section == 1{
			cell.textLabel?.text = NSLocalizedString("D", comment: "") + String(draw[indexPath.row])
		}else{
			cell.textLabel?.text = models[indexPath.row].1
		}
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		var number: Int = 0
		
		if indexPath.section == 0{
			return
			
		}else if indexPath.section == 1{
			for _ in 0...numOfDices - 1{
				let dSize = draw[indexPath.row]
				number = d(dSize) + number
			}
			
		}else{
			number = models[indexPath.row].0(numOfDices)
		}
		
        let message = NSLocalizedString("Drawn", comment: "") + " " + String(number)
        whisper(messege: message)
        
        let action = NSMutableDictionary()
        let at = NSNumber(value: ActionType.generatedRandomNumber.rawValue)
 
        action.setValue(at, forKey: "action")
        action.setValue(number, forKey: "number")
        
        PackageService.pack.send(action)
        
        return
    }
}

class StepperCell: UITableViewCell {
	
	var delegate: StepperCellDelegate?
	
	@IBOutlet weak var stepper: UIStepper!
	
	@IBAction func valueChanged(_ sender: UIStepper) {
		delegate?.valueChaged(sender)
	}
}

protocol StepperCellDelegate {
	func valueChaged(_ sender: UIStepper)
}
