//
//  TeamViewCellSubCells.swift
//  RPGAapp
//
//  Created by Jakub on 14.05.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class newAbilityCell: UITableViewCell,UITextFieldDelegate{
	
	var character: Character!
	
	var newAbilityDelegate: AbilityCellDelegate!
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		
		guard textField.text?.replacingOccurrences(of: " ", with: "").characters.count != 0 else{
			return true
		}
		
		if let text = textField.text{
			let context = CoreDataStack.managedObjectContext
			let newAbility = NSEntityDescription.insertNewObject(forEntityName: String(describing: Ability.self), into: context) as! Ability
			
			newAbility.name = text
			newAbility.character = character
			newAbility.id = String(strHash(newAbility.name + newAbility.character.id! + String(describing: Date())))
			
			CoreDataStack.saveContext()
			
			newAbilityDelegate.modifiedAbility()
			
			let action = NSMutableDictionary()
			let actionType = NSNumber(value: ActionType.addedAbilityToCharacter.rawValue)
			
			action.setValue(actionType, forKey: "action")
			
			action.setValue(newAbility.name, forKey: "abilityName")
			action.setValue(newAbility.id, forKey: "abilityId")
			action.setValue(newAbility.value, forKey: "abilityValue")
			action.setValue(character.id, forKey: "characterId")
			
			let appDelegate = UIApplication.shared.delegate as! AppDelegate
			
			appDelegate.pack.send(action)
			
			textField.text = ""
		}
		
		return true
	}
}

protocol AbilityCellDelegate {
	
	func modifiedAbility()
}


class abilityCell: UITableViewCell {
	
	var character: Character!
	
	var ability: Ability!
	
	var abilityDelgate: AbilityCellDelegate!
	
	@IBOutlet weak var stepper: UIStepper!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		NotificationCenter.default.addObserver(self, selector: #selector(valueOfAblitityChanged(_:)), name: .valueOfAblitityChanged, object: nil)
		
		let removeAbilityLongPress = UILongPressGestureRecognizer(target: self, action: #selector(removeAbility(_:)))
		self.contentView.addGestureRecognizer(removeAbilityLongPress)
	}
	
	func valueOfAblitityChanged(_ notification: Notification){
		guard let idOfChanged = notification.object as? String else{
			return
		}
		
		if ability.id == idOfChanged{
			self.textLabel?.text = ability.name + ": " + String(ability.value)
		}
	}
	
	func removeAbility(_ sender: UILongPressGestureRecognizer){
		
		switch sender.state {
		case .ended:
			let contex = CoreDataStack.managedObjectContext
			
			let abilityId = ability.id
			
			character.removeFromAbilities(ability)
			contex.delete(ability)
			
			CoreDataStack.saveContext()
			
			abilityDelgate.modifiedAbility()
			
			self.backgroundColor = UIColor.white
			
			let action = NSMutableDictionary()
			let actionType = NSNumber(value: ActionType.removeAbility.rawValue)
			
			action.setValue(actionType, forKey: "action")
			
			action.setValue(abilityId, forKey: "abilityId")
			action.setValue(character.id, forKey: "characterId")
			
			let appDelegate = UIApplication.shared.delegate as! AppDelegate
			
			appDelegate.pack.send(action)
			
		case .began:
			UIView.animate(withDuration: sender.minimumPressDuration, animations: {
				self.backgroundColor = UIColor.red
			})
			
		default:
			self.backgroundColor = UIColor.white
		}
	}
	
	@IBAction func valueChanged(_ sender: UIStepper) {
		ability.value = Int16(sender.value)
		
		CoreDataStack.saveContext()
		
		self.textLabel?.text = ability.name + ": " + String(describing: ability.value)
		
		let action = NSMutableDictionary()
		let actionType = NSNumber(value: ActionType.valueOfAblilityChanged.rawValue)
		
		abilityDelgate.modifiedAbility()
		
		action.setValue(actionType, forKey: "action")
		
		action.setValue(ability.id, forKey: "abilityId")
		action.setValue(ability.value, forKey: "abilityValue")
		action.setValue(character.id, forKey: "characterId")
		
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		
		appDelegate.pack.send(action)
	}
}

protocol CharacterItemCellDelegate {
	
	func modifiedItemHandler()
}

class characterItemCell: UITableViewCell {
	
	var itemHandler: ItemHandler!
	
	var character: Character!
	
	var itemHandlerDelegate: CharacterItemCellDelegate!
	
	@IBOutlet weak var detailLabel: UILabel!
	
	@IBOutlet weak var stepper: UIStepper!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		NotificationCenter.default.addObserver(self, selector: #selector(equipmentChanged), name: .equipmentChanged, object: nil)
		
		let removeAbilityLongPress = UILongPressGestureRecognizer(target: self, action: #selector(removeItem(_:)))
		self.contentView.addGestureRecognizer(removeAbilityLongPress)
	}
	
	
	@IBAction func valueChanged(_ sender: UIStepper) {
		
		detailLabel.text = String(Int(sender.value))
		
		itemHandler.count = Int64(sender.value)
		
		CoreDataStack.saveContext()
		
		let action = NSMutableDictionary()
		let actionType = NSNumber(value: ActionType.itemHandlerCountChanged.rawValue)
		
		action.setValue(actionType, forKey: "action")
		
		action.setValue(itemHandler.count, forKey: "itemCount")
		action.setValue(itemHandler.item?.id, forKey: "itemId")
		action.setValue(character.id, forKey: "characterId")
		
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		
		appDelegate.pack.send(action)
	}
	
	func equipmentChanged(){
		detailLabel.text = String(itemHandler.count)
	}
	
	func removeItem(_ sender: UILongPressGestureRecognizer){
		switch sender.state {
		case .ended:
			let contex = CoreDataStack.managedObjectContext
			
			let itemId = itemHandler.item?.id
			
			character.removeFromEquipment(itemHandler)
			contex.delete(itemHandler)
			
			CoreDataStack.saveContext()
			
			itemHandlerDelegate.modifiedItemHandler()
			
			self.backgroundColor = UIColor.white
			
			let action = NSMutableDictionary()
			let actionType = NSNumber(value: ActionType.itemDeletedFromCharacter.rawValue)
			
			action.setValue(actionType, forKey: "action")
			
			action.setValue(itemId, forKey: "itemId")
			action.setValue(character.id, forKey: "characterId")
			
			let appDelegate = UIApplication.shared.delegate as! AppDelegate
			
			appDelegate.pack.send(action)
			
		case .began:
			UIView.animate(withDuration: sender.minimumPressDuration, animations: {
				self.backgroundColor = UIColor.red
			})
			
		default:
			self.backgroundColor = UIColor.white
		}
	}	
}

