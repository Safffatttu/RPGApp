
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

class EditDrawSetting: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate{
    
    var editingMode = false
	var setting: DrawSetting? = nil{
		didSet{
			subSettings = setting?.subSettings?.sortedArray(using: [.sortSubSettingByName]) as! [DrawSubSetting]
		}
	}
	
	var subSettings: [DrawSubSetting] = []
	
    var categories: [Category] = Load.categories()
    var subCategories: [SubCategory] = Load.subCategories()
    
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

		for index in 0...rarityName.count - 1{
			let setEnable = rarity <= index
			maxRaritySegmented.setEnabled(setEnable, forSegmentAt: index)
		}
	}
    
    @IBAction func maxRaritySegementedtChanged(_ sender: UISegmentedControl) {
		
        let rarity = sender.selectedSegmentIndex
		
		for index in 0...rarityName.count - 1{
			let setEnable = rarity >= index
			minRaritySegmented.setEnabled(setEnable, forSegmentAt: index)
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
            
            let min = subSetting.minRarity > 0 ? "Min: " + rarityName[Int(subSetting.minRarity) - 1] + " " : ""
            let max = subSetting.maxRarity < 3 ? "Max: " + rarityName[Int(subSetting.maxRarity) - 1] + " " : ""
            
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
			
            subDraw.minRarity = Int16(minRaritySegmented.selectedSegmentIndex)
            subDraw.maxRarity = Int16(maxRaritySegmented.selectedSegmentIndex)
            setting?.addToSubSettings(subDraw)
			
			let newSubSettingIndex = IndexPath(row: subSettings.count, section: 0)
			
			subSettings.append(subDraw)
			
			subSettingsTable.insertRows(at: [newSubSettingIndex], with: .left)
			
			setupSegmentControll()
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
		}
	}
	
	
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
		
        return allowedCharacters.isSuperset(of: characterSet)
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
