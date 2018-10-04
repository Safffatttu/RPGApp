
//
//  TeamViewCell.swift
//  RPGAapp
//
//  Created by Jakub on 14.05.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import UIKit
import Dwifft
import FontAwesome_swift

class TeamViewCell: UICollectionViewCell {
	
	@IBOutlet weak var abilityTable: UITableView!
	@IBOutlet weak var equipmentTable: UITableView!
	@IBOutlet weak var visibilitiesTable: UITableView!
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var raceLabel: UILabel!
	@IBOutlet weak var professionLabel: UILabel!
	@IBOutlet weak var healthLabel: UILabel!
	@IBOutlet weak var healthStepper: UIStepper!
	
	@IBOutlet weak var moneyLabel: UILabel!
	@IBOutlet weak var moneyTextField: UITextField!
	
	@IBOutlet weak var abilityLabel: UILabel!
	@IBOutlet weak var equipmentLabel: UILabel!
	@IBOutlet weak var visibilitiesLabel: UILabel!
	
	@IBOutlet weak var deleteButton: UIButton!
	@IBOutlet weak var editButton: UIButton!
	
	var abilityDiffCalculator: SingleSectionTableViewDiffCalculator<Ability>?
	var equipmentDiffCalculator: SingleSectionTableViewDiffCalculator<ItemHandler>?
	var visibilitiesDiffCalculator: SingleSectionTableViewDiffCalculator<Visibility>?
	
	var character: Character!{
		didSet{
			abilities = character.abilities?.sortedArray(using: [.sortAbilityByName]) as? [Ability]
			items = character.equipment?.sortedArray(using: [.sortItemHandlerByName]) as? [ItemHandler]
			visibilities = Load.visibilities()
			
			reloadLabels()
		}
	}
	
	var abilities: [Ability]!{
		didSet{
			abilityDiffCalculator?.rows = abilities
		}
	}
	
	var items: [ItemHandler]!{
		didSet{
			equipmentDiffCalculator?.rows = items
		}
	}
	
	var visibilities: [Visibility]!{
		didSet{
			visibilitiesDiffCalculator?.rows = visibilities
		}
	}
	
	override func awakeFromNib() {
		equipmentTable.dataSource = self
		abilityTable.dataSource = self
		visibilitiesTable.dataSource = self
		visibilitiesTable.delegate = self
		moneyTextField.delegate = self
		
		equipmentDiffCalculator = SingleSectionTableViewDiffCalculator(tableView: equipmentTable)
		abilityDiffCalculator = SingleSectionTableViewDiffCalculator(tableView: abilityTable, initialRows: [], sectionIndex: 0)
		visibilitiesDiffCalculator = SingleSectionTableViewDiffCalculator(tableView: visibilitiesTable, initialRows: [], sectionIndex: 0)
		
		let iconSize: CGFloat = 25
		
		deleteButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize)
		deleteButton.setTitle(String.fontAwesomeIcon(name: .times), for: .normal)
		
		editButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize)
		editButton.setTitle(String.fontAwesomeIcon(name: .edit), for: .normal)
		
		abilityLabel.text = NSLocalizedString("Abilities", comment: "")
		equipmentLabel.text = NSLocalizedString("Equipment", comment: "")
		moneyLabel.text = NSLocalizedString("Money", comment: "")
		visibilitiesLabel.text = NSLocalizedString("Visibilities", comment: "")
		
		NotificationCenter.default.addObserver(self, selector: #selector(modifiedAbility), name: .modifiedAbility, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(equipmentChanged), name: .equipmentChanged, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(reloadLabels) , name: .reloadTeam, object: nil)
		super.awakeFromNib()
	}
	
	func equipmentChanged(){
		if let newItems = character.equipment?.sortedArray(using: [.sortItemHandlerByName]) as? [ItemHandler] {
			items = newItems
		}
	}
	
	func reloadLabels(){
		if let name = character.name{
			nameLabel.text = NSLocalizedString("Name", comment: "") + ": \(name)"
		}else{
			nameLabel.text = ""
		}
		
		if let race = character.race{
			if race.characters.count > 0{
				raceLabel.text = NSLocalizedString("Character", comment: "") + ": \(race)"
			}else{
				raceLabel.text = ""
			}
		}else{
			raceLabel.text = ""
		}
		
		if let profession = character.profession{
			if profession.characters.count > 0{
				professionLabel.text = NSLocalizedString("Profession", comment: "") + ": \(profession)"
			}else{
				professionLabel.text = ""
			}
		}else{
			professionLabel.text = ""
		}
		
		healthLabel.text = "\(NSLocalizedString("Health", comment: "")): \(character.health)"
		healthStepper.value = Double(character.health)
		
		moneyTextField.text = showPrice(character.money)
		
		visibilities = Load.visibilities()
		
		if Load.currentVisibility() == nil && visibilities.count > 0{
			visibilitiesTable.isHidden = false
			visibilitiesLabel.isHidden = false
		}else {
			visibilitiesTable.isHidden = true
			visibilitiesLabel.isHidden = true
		}
	}
	
	@IBAction func removeCharacter() {
		let alertTitle = NSLocalizedString("Are you sure you want to remove character?", comment: "")
		let alert = UIAlertController(title: alertTitle, message: "", preferredStyle: .alert)
		
		let localizedYes = NSLocalizedString("Yes", comment: "")
		let alertYes = UIAlertAction(title: localizedYes, style: .destructive, handler: { (alert: UIAlertAction!) -> Void in
			let context = CoreDataStack.managedObjectContext
			
			let characterId = self.character.id
			context.delete(self.character)
			
			CoreDataStack.saveContext()
						
			NotificationCenter.default.post(name: .reloadTeam, object: nil)
			
			let action = CharacterRemoved(characterId: characterId!)			
			PackageService.pack.send(action: action)
		})
		
		let localizedNo = NSLocalizedString("No", comment: "")
		let alertNo = UIAlertAction(title: localizedNo, style: .cancel)
		
		alert.addAction(alertNo)
		alert.addAction(alertYes)
		
		next(UICollectionViewController.self)?.present(alert, animated: true, completion: nil)
	}

	@IBAction func editCharacter() {
		NotificationCenter.default.post(name: .modifyCharacter, object: character)
	}
	
	@IBAction func changedPlayerMoney(_ sender: UITextField) {
		guard let text = sender.text else { return }
		let value = convertCurrencyToValue(text)
		
		character.money = value
		
		CoreDataStack.saveContext()
	}
	
	@IBAction func healthChanged(_ sender: UIStepper) {
		character.health = Int16(sender.value)
		healthLabel.text = "\(NSLocalizedString("Health", comment: "")) \(character.health)"
		
		CoreDataStack.saveContext()
	}
}

extension TeamViewCell: UITableViewDataSource, UITableViewDelegate{
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if tableView == abilityTable{
			return (abilityDiffCalculator?.rows.count)! + 1
		}else if tableView == equipmentTable{
			return (equipmentDiffCalculator?.rows.count)!
		}else {
			return (visibilitiesDiffCalculator?.rows.count)! + 1
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell") as? characterItemCell {
			let cellItem = equipmentDiffCalculator?.rows[indexPath.row]
			
			cell.itemHandlerDelegate = self
			
			if let name = cellItem?.item?.name, let count = cellItem?.count{
				cell.textLabel?.text = "\(name) \(count)"
			}
			
			cell.stepper.value = Double((cellItem?.count)!)
			cell.itemHandler = cellItem
			cell.character = character
			return cell
		}else if tableView == abilityTable{
			if indexPath.row == abilities.count{
				
				let cell = tableView.dequeueReusableCell(withIdentifier: "newAbilityCell") as? newAbilityCell
				
				cell?.newAbilityDelegate = self
				cell?.character = character
				
				return cell!
			}else{
				let cell = tableView.dequeueReusableCell(withIdentifier: "abilityCell") as? abilityCell
				
				cell?.abilityDelgate = self
				
				let ability = abilityDiffCalculator?.rows[indexPath.row]
				let abilityToShow = (ability?.name)! + ": " + String(describing: (ability?.value)!)
				
				cell?.ability = ability
				cell?.character = character
				cell?.textLabel?.text = abilityToShow
				
				return cell!
			}
		}else{
			let cell = tableView.dequeueReusableCell(withIdentifier: "visibilityCell")

			cell?.accessoryType = .none
			cell?.selectionStyle = .none
			
			if indexPath.row == visibilities.count{
				if character.visibility == nil{
					cell?.accessoryType = .checkmark
				}
				
				cell?.textLabel?.text = NSLocalizedString("Always visable", comment: "")
				
			}else{
				if character.visibility == visibilitiesDiffCalculator?.rows[indexPath.row]{
					cell?.accessoryType = .checkmark
				}
				
				cell?.textLabel?.text = visibilitiesDiffCalculator?.rows[indexPath.row].name ?? ""
			}
			
			return cell!
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard tableView == visibilitiesTable else { return }
		
		let index = indexPath.row
		
		var newVisibility: Visibility? = nil
		
		if index < visibilities.count{
			newVisibility = visibilities[index]
		}
		
		let previousIndex: IndexPath!
		
		if let previousVisibility = character.visibility{
			guard let previousVisibilityNumber = visibilities.index(of: previousVisibility) else { return }
			previousIndex = IndexPath(row: previousVisibilityNumber, section: 0)
		}else{
			previousIndex = IndexPath(row: visibilities.count, section: 0)
		}
		
		guard previousIndex != indexPath else { return }
		
		character.visibility = newVisibility
		
		let newCell = visibilitiesTable.cellForRow(at: indexPath)
		let previousCell = visibilitiesTable.cellForRow(at: previousIndex)
		
		newCell?.accessoryType = .checkmark
		previousCell?.accessoryType = .none
		
		CoreDataStack.saveContext()
		
		let action = CharacterVisibilityChanged(character: character, visibility: newVisibility)
		PackageService.pack.send(action: action)
	}
}

extension TeamViewCell: UITextFieldDelegate{
	func textFieldShouldReturn(_ textField: UITextField) -> Bool{
		guard let text = moneyTextField.text else { return true }

		let money = convertCurrencyToValue(text)
		character.money = money
		
		textField.resignFirstResponder()
		
		CoreDataStack.saveContext()
		
		let action = CharacterMoneyChanged(character: character)
		PackageService.pack.send(action: action)
		
		return true
	}
}

extension TeamViewCell: AbilityCellDelegate{
	
	func modifiedAbility() {
		if let abs = character.abilities?.sortedArray(using: [.sortAbilityByName]) as? [Ability]{
			self.abilities = abs
		}
	}
}

extension TeamViewCell: CharacterItemCellDelegate{
	
	func modifiedItemHandler() {
		if let newItems = character.equipment?.sortedArray(using: [.sortItemHandlerByName]) as? [ItemHandler]{
			items = newItems
		}
	}
}
