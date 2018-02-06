//
//  TeamView.swift
//  RPGAapp
//
//  Created by Jakub on 10.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TeamView: UICollectionViewController {
    
    var team: [Character] = []
    
    override func viewDidLoad() {
        let addButton =  UIBarButtonItem.init(title: "Add", style: .plain, target: self, action: #selector(addCharacter(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTeam), name: .reloadTeam, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addItem(_:)), name: .itemAddedToCharacter, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteItem(_:)), name: .itemDeletedFromCharacter, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(addedNewAbility(_:)), name: .addedNewAbility, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(valueOfAblitityChanged(_:)), name: .valueOfAbilityChanged, object: nil)
		
		reloadTeam()
        super.viewDidLoad()
    }
    
    func addItem(_ notification: NSNotification){
        let action = notification.object as! NSMutableDictionary
        let characterNumber = action.value(forKey: "characterNumber") as! Int
        let cell = self.collectionView?.cellForItem(at: IndexPath(item: characterNumber, section: 0)) as! TeamViewCell
        
        if let itemNumber = action.value(forKey: "itemNumber") as? Int{
            if (action.value(forKey: "createdNewHandler") as! Bool){
                let index = IndexPath(item: itemNumber, section: 0)
                cell.table.insertRows(at: [index], with: .left)
            }else{
                let index = IndexPath(item: itemNumber, section: 0)
                cell.table.reloadRows(at: [index], with: .fade)
            }
        }else{
            cell.table.reloadData()
        }
    }
    
    func deleteItem(_ notification: NSNotification){
        let action = notification.object as! NSMutableDictionary
        let characterNumber = action.value(forKey: "characterNumber") as! Int
        let itemNumber = action.value(forKey: "itemNumber") as! Int
        
        let cell = self.collectionView?.cellForItem(at: IndexPath(item: characterNumber, section: 0)) as! TeamViewCell
        
        let index = IndexPath(item: itemNumber, section: 0)
        cell.table.deleteRows(at: [index], with: .left)
    }
    
    func addCharacter(_ sender: Any){
        if !sessionIsActive(){
            return
        }
        let addCharControler = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addCharacter")
        addCharControler.modalPresentationStyle = .formSheet
        self.present(addCharControler, animated: true, completion: nil)
    }
	
	func addedNewAbility(_ notification: Notification){
		guard let object = notification.object as? (String,String) else{
			return
		}
		let characterId = object.0
		let abilityId = object.1
		
		guard let characterIndex = team.index(where: {$0.id == characterId}) else {return}
		let cellIndex = IndexPath(row: characterIndex, section: 0)
		
		guard let abilityIndex = team.first(where: {$0.id == characterId})?.abilities?.sortedArray(using: [.sortAbilityByName]).index(where: { ($0 as! Ability).id == abilityId})
			else { return }
		let tableCellIndex = IndexPath(row: abilityIndex, section: 0)
		
		guard let cell = self.collectionView?.cellForItem(at: cellIndex) as? TeamViewCell else {return}
		
		cell.ablilityTable.insertRows(at: [tableCellIndex], with: .automatic)
	}
	
	func valueOfAblitityChanged(_ notification: Notification){
		guard let object = notification.object as? (String,String) else{
			return
		}
		let characterId = object.0
		let abilityId = object.1

		guard let characterIndex = team.index(where: {$0.id == characterId}) else {return}
		let cellIndex = IndexPath(row: characterIndex, section: 0)
		
		guard let character = team.first(where: {$0.id == characterId}) else { return }
		
		guard let ability = character.abilities?.first(where: {($0 as! Ability).id == abilityId}) as? Ability else { return }
		
		guard let abilityIndex = character.abilities?.sortedArray(using: [.sortAbilityByName]).index(where: {($0 as! Ability) == ability}) else { return }
		let tableCellIndex = IndexPath(row: abilityIndex, section: 0)
		
		guard let teamCell = self.collectionView?.cellForItem(at: cellIndex) as? TeamViewCell else {return}
		
		let abilityCell = teamCell.ablilityTable.cellForRow(at: tableCellIndex) as? abilityCell
		abilityCell?.textLabel?.text = (ability.name)! + ": " + String(describing: (ability.value))
		abilityCell?.stepper.value = Double(ability.value)
		return
	}
	
    func reloadTeam(){
        let session = getCurrentSession()
		
        team = session.characters?.sortedArray(using: [.sortCharacterById]) as! [Character]
        
        collectionView?.reloadData()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return team.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TeamViewCell
        let person = team[indexPath.row]
        cell.nameLabel.text = person.name
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? TeamViewCell else { return }
        tableViewCell.setTableViewDataSourceDelegate(self, forRow: indexPath.row)
    }
}

extension TeamView: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = tableView.dequeueReusableCell(withIdentifier: "itemCell"){
            return team[tableView.tag].equipment!.count
		}else{
			return team[tableView.tag].abilities!.count + 1
		}
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell") {
            let equipment = team[tableView.tag].equipment!.sortedArray(using: [.sortItemHandlerByName]) as! [ItemHandler]
            cell.textLabel?.text = (equipment[indexPath.row].item?.name)!
            cell.detailTextLabel?.text = String(describing: equipment[indexPath.row].count)
            return cell
        }
        
        else{
			if indexPath.row == self.tableView(tableView, numberOfRowsInSection: 0) - 1{
				let cell = tableView.dequeueReusableCell(withIdentifier: "newAbilityCell") as? newAbilityCell
				cell?.character = team[tableView.tag]
				return cell!
			}else{
				let cell = tableView.dequeueReusableCell(withIdentifier: "abilityCell") as? abilityCell
				
				let ability = team[tableView.tag].abilities?.sortedArray(using: [.sortAbilityByName])[indexPath.row] as! Ability
				let abilityToShow = (ability.name)! + ": " + String(describing: (ability.value))
				
				cell?.ability = ability
				cell?.character = team[tableView.tag]
				cell?.textLabel?.text = abilityToShow
				
				return cell!
			}
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView.dequeueReusableCell(withIdentifier: "itemCell") != nil && sessionIsActive(show: false){
            return true
        }else{
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell")
        if cell != nil && editingStyle == .delete{
            let equipment = team[tableView.tag].equipment!.sortedArray(using: [.sortItemHandlerByName]) as! [ItemHandler]
            
            let action = NSMutableDictionary()
            let at = NSNumber(value: ActionType.itemDeletedFromCharacter.rawValue)
            action.setValue(at, forKey: "action")
            
            action.setValue(team[tableView.tag].id, forKey: "characterId")
            action.setValue(tableView.tag, forKey: "characterNumber")
            action.setValue(equipment[indexPath.row].item?.id, forKey: "itemId")
            action.setValue(indexPath.row, forKey: "itemNumber")
            
            team[tableView.tag].removeFromEquipment(equipment[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .automatic)
            CoreDataStack.saveContext()
            
            let packageService = (UIApplication.shared.delegate as! AppDelegate).pack
            packageService.send(action)
            return
        }
    }
}

class TeamViewCell: UICollectionViewCell {
    
    @IBOutlet var table: UITableView!
    
    @IBOutlet var ablilityTable: UITableView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    func setTableViewDataSourceDelegate<D: UITableViewDataSource & UITableViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        table.delegate = dataSourceDelegate
        table.dataSource = dataSourceDelegate
        table.tag = row
        ablilityTable.delegate = dataSourceDelegate
        ablilityTable.dataSource = dataSourceDelegate
        ablilityTable.tag = row
    }
}

class newAbilityCell: UITableViewCell,UITextFieldDelegate {
	
	var character: Character!
	
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
			newAbility.id = String(strHash(newAbility.name! + (newAbility.character?.id)! + String(describing: Date())))
			
			CoreDataStack.saveContext()
			
			NotificationCenter.default.post(name: .addedNewAbility, object: (character.id,newAbility.id))
			
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

class abilityCell: UITableViewCell {

	var character: Character!
	
	var ability: Ability!
	
	@IBOutlet weak var stepper: UIStepper!
	
	@IBAction func valueChanged(_ sender: UIStepper) {
		let index = getCurrentCellIndexPath(sender, tableView: next(UITableView.self)!)
		
		ability.value = Int16(sender.value)
		
		CoreDataStack.saveContext()
		
		self.textLabel?.text = (ability.name)! + ": " + String(describing: (ability.value))
		
		let action = NSMutableDictionary()
		let actionType = NSNumber(value: ActionType.valueOfAblilityChanged.rawValue)
		
		action.setValue(actionType, forKey: "action")
		
		action.setValue(ability.id, forKey: "abilityId")
		action.setValue(ability.value, forKey: "abilityValue")
		action.setValue(character.id, forKey: "characterId")
		
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		
		appDelegate.pack.send(action)
	}
}

extension Notification.Name{
    static let reloadTeam = Notification.Name("reloadTeam")
    static let reloadCharacterItems = Notification.Name("reloadCharacterItems")
    static let itemDeletedFromCharacter = Notification.Name("itemDeletedFromCharacter")
	static let addedNewAbility = Notification.Name("addedNewAbility")
	static let valueOfAbilityChanged = Notification.Name("valueOfAbilityChanged")
}
