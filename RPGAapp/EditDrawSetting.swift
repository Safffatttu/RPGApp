//
//  editDrawSetting.swift
//  RPGAapp
//
//  Created by Jakub on 04.09.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class EditDrawSetting: UIViewController {
    
    var editingMode = false
	var setting: DrawSetting? = nil{
		didSet{
			subSettings = setting?.subSettings?.sortedArray(using: [.sortSubSettingByName]) as! [DrawSubSetting]
		}
	}
	
	var subSettings: [DrawSubSetting] = []
	
    var categories: [Category] = Load.categories()
    var subCategories: [SubCategory] = Load.subCategories()
	
	var selectedSubSetting: DrawSubSetting? = nil
	
    @IBOutlet weak var subSettingsTable: UITableView!
    @IBOutlet weak var categoriesTable: UITableView!
    
    @IBOutlet weak var drawSettingNameField: UITextField!
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var numberField: UITextField!
	
    @IBOutlet weak var minRarityLabel: UILabel!
	@IBOutlet weak var minRaritySegmented: UISegmentedControl!
    
    @IBOutlet weak var maxRarityLabel: UILabel!
	@IBOutlet weak var maxRaritySegmented: UISegmentedControl!
	
    override func viewWillAppear(_ animated: Bool) {
        self.preferredContentSize = CGSize(width: 400, height: 400)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(_:)))
        
        self.numberField.delegate = self
		
		self.navigationController?.title = NSLocalizedString("Preset Editor", comment: "")
        
        if setting == nil{
            let context = CoreDataStack.managedObjectContext
            setting = NSEntityDescription.insertNewObject(forEntityName: String(describing: DrawSetting.self), into: context) as? DrawSetting
        }
        
        numberLabel.text = NSLocalizedString("Number of items", comment: "")
        minRarityLabel.text = NSLocalizedString("Minimal rarity", comment: "")
        maxRarityLabel.text = NSLocalizedString("Maximal rarity", comment: "")
		
		setupSegmentControll()
		
        super.viewWillAppear(animated)
    }
    
    @IBAction func minRaritySegmentedChanged(_ sender: UISegmentedControl) {
		let rarity = sender.selectedSegmentIndex
		enableSegments(in: maxRaritySegmented, from: rarity, to: maxRaritySegmented.numberOfSegments - 1)
		
		guard let selectedSubSetting = selectedSubSetting else { return }
		selectedSubSetting.minRarity = Int16(rarity + 1)
		
		reloadSelectedSubSetting()
	}
    
    @IBAction func maxRaritySegementedtChanged(_ sender: UISegmentedControl){
		let rarity = sender.selectedSegmentIndex
		enableSegments(in: minRaritySegmented, from: 0, to: rarity)
		
		guard let selectedSubSetting = selectedSubSetting else { return }
		selectedSubSetting.maxRarity = Int16(rarity + 1)
		
		reloadSelectedSubSetting()
	}
	
	func reloadSelectedSubSetting(){
		guard let selectedSubSetting = selectedSubSetting else { return }
		guard let index = subSettings.index(of: selectedSubSetting) else { return }
		
		let indexPath = IndexPath(row: index, section: 0)
		subSettingsTable.reloadRows(at: [indexPath], with: .automatic)
	}
	
	func enableSegments(in segmentControl: UISegmentedControl, from: Int, to: Int){
		let numberOfSegments = segmentControl.numberOfSegments
		for index in 0...numberOfSegments - 1{
			let enabled = (from <= index && to >= index)
			segmentControl.setEnabled(enabled, forSegmentAt: index)
		}
    }
	
	func setupSegmentControll(){
		let segmentWidth = minRaritySegmented.frame.width
		
		minRaritySegmented.removeAllSegments()
		for (index, rarity) in rarityName.enumerated(){
			minRaritySegmented.insertSegment(withTitle: rarity, at: index, animated: false)
			let width = segmentWidth * widthForSegmentOfRarityName(num: index)
			minRaritySegmented.setWidth(width, forSegmentAt: index)
			minRaritySegmented.setEnabled(true, forSegmentAt: index)
		}
		minRaritySegmented.selectedSegmentIndex = 0
		
		maxRaritySegmented.removeAllSegments()
		for (index, rarity) in rarityName.enumerated(){
			maxRaritySegmented.insertSegment(withTitle: rarity, at: index, animated: false)
			let width = segmentWidth * widthForSegmentOfRarityName(num: index)
			maxRaritySegmented.setWidth(width, forSegmentAt: index)
			maxRaritySegmented.setEnabled(true, forSegmentAt: index)
		}
		maxRaritySegmented.selectedSegmentIndex = rarityName.count - 1
	}
	
	func addSubSetting(at indexPath: IndexPath){
		selectedSubSetting = nil
		
		let context = CoreDataStack.managedObjectContext
		let subDraw = NSEntityDescription.insertNewObject(forEntityName: String(describing: DrawSubSetting.self), into: context) as! DrawSubSetting
		
		if indexPath.section == 0{
			subDraw.name = NSLocalizedString("All items", comment: "")
		}else{
			if indexPath.row == 0{
				subDraw.category = categories[indexPath.section - 1]
				subDraw.name = subDraw.category?.name
			}else{
				subDraw.subCategory = categories[indexPath.section - 1].subCategories?.sortedArray(using: [.sortSubCategoryByName])[indexPath.row - 1] as? SubCategory
				subDraw.name = subDraw.subCategory?.name
			}
		}
		
		if numberField.text != nil && !(numberField.text?.isEmpty)!{
			subDraw.itemsToDraw = Int64((numberField?.text)!)!
		}else{
			subDraw.itemsToDraw = 10
		}
		
		subDraw.minRarity = Int16(minRaritySegmented.selectedSegmentIndex + 1)
		subDraw.maxRarity = Int16(maxRaritySegmented.selectedSegmentIndex + 1)
		setting?.addToSubSettings(subDraw)
		
		let newSubSettingIndex = IndexPath(row: subSettings.count, section: 0)
		
		subSettings.append(subDraw)
		
		subSettingsTable.insertRows(at: [newSubSettingIndex], with: .left)
		
		setupSegmentControll()
	}
	
	func selectSubSetting(at indexPath: IndexPath){
		selectedSubSetting = subSettings[indexPath.row]
		
		numberField.text = String((selectedSubSetting?.itemsToDraw)!)
		
		if let minRarity = selectedSubSetting?.minRarity{
			minRaritySegmented.selectedSegmentIndex = Int(minRarity - 1)
			enableSegments(in: maxRaritySegmented, from: Int(minRarity - 1), to: maxRaritySegmented.numberOfSegments - 1)
		}
		
		if let maxRarity = selectedSubSetting?.maxRarity{
			maxRaritySegmented.selectedSegmentIndex = Int(maxRarity - 1)
			enableSegments(in: minRaritySegmented, from: 0, to: Int(maxRarity - 1))
		}
	}
	
    func done(_ sender: UIBarButtonItem){
		guard setting?.subSettings?.count != 0 else { return }
		
        setting?.name = drawSettingNameField.text!
        CoreDataStack.saveContext()
		
        NotificationCenter.default.post(name: .reloadDrawSettings, object: nil)
		
        dismiss(animated: true, completion: nil)
    }
    
    func cancel(_ sender: UIBarButtonItem){
        if !editingMode{
            CoreDataStack.managedObjectContext.delete(setting!)
			
		}
		
        dismiss(animated: true, completion: nil)
    }
}

extension EditDrawSetting: UITableViewDataSource, UITableViewDelegate{
	
	func numberOfSections(in tableView: UITableView) -> Int {
		if tableView == categoriesTable{
			return categories.count + 1
		}else{
			return 1
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if tableView == categoriesTable{
			if section == 0{
				return 1
			}else{
				return (categories[section - 1].subCategories?.count)! + 1
			}
        }else{
            return subSettings.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == categoriesTable{
			if section == 0{
				return NSLocalizedString("All items", comment: "")
			}else{
				return categories[section - 1].name
			}
		}else{
			return NSLocalizedString("Selected categories", comment: "")
		}
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell?
        if tableView == categoriesTable{
            cell = tableView.dequeueReusableCell(withIdentifier: "categoriesCell")
			
			if indexPath.section == 0{
				cell?.textLabel?.text = NSLocalizedString("All items", comment: "")
			}else{
				if indexPath.row == 0{
					cell?.textLabel?.text = NSLocalizedString("Whole category", comment: "") + " " + categories[indexPath.section - 1].name!
				}else{
					let cellCategory = categories[indexPath.section - 1]
					let cellSubCategories = cellCategory.subCategories?.sortedArray(using: [.sortSubCategoryByName]) as! [SubCategory]
					cell?.textLabel?.text = cellSubCategories[indexPath.row - 1].name
				}
				
				cell?.detailTextLabel?.font = UIFont.fontAwesome(ofSize: CGFloat(20))
				cell?.detailTextLabel?.text = String.fontAwesomeIcon(name: .send)
			}
			
		}else{
			cell = tableView.dequeueReusableCell(withIdentifier: "drawSubSettingCell")
			let subSetting = subSettings[indexPath.row]
			
			let min = subSetting.minRarity > 1 ? "Min: " + rarityName[Int(subSetting.minRarity) - 1] + " " : ""
			let max = subSetting.maxRarity < 4 ? "Max: " + rarityName[Int(subSetting.maxRarity) - 1] + " " : ""
			
			if let subName = subSetting.name {
				cell?.textLabel?.text = subName
			}else{
				cell?.textLabel?.text = ""
			}
			
			cell?.detailTextLabel?.text = min + max + NSLocalizedString("Amount", comment: "") + ": " + String(subSetting.itemsToDraw)
		}
		
		return cell!
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if tableView == categoriesTable{
			addSubSetting(at: indexPath)
		}else{
			selectSubSetting(at: indexPath)
		}
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		if tableView == subSettingsTable{
			return true
		}else{
			return false
		}
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete{
			let subToRemove = subSettings[indexPath.row]
			
			setting?.removeFromSubSettings(subToRemove)
			subSettings.remove(at: indexPath.row)
			
			tableView.deleteRows(at: [indexPath], with: .left)
			
			selectedSubSetting = nil
			numberField.text = ""
			setupSegmentControll()
		}
	}
}

extension EditDrawSetting: UITextFieldDelegate{
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let allowedCharacters = CharacterSet.decimalDigits
		let characterSet = CharacterSet(charactersIn: string)
		
		return allowedCharacters.isSuperset(of: characterSet)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		guard let text = textField.text else { return true }
		guard let value = Int64(text) else { return true }
		
		guard let selectedSubSetting = selectedSubSetting else { return true }
		selectedSubSetting.itemsToDraw = value
		
		reloadSelectedSubSetting()
		
		return true
	}
}
