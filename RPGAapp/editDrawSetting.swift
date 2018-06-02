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
    var setting: DrawSetting? = nil
    
    var categories: [Category] = Load.categories()
    var subCategories: [SubCategory] = Load.subCategories()
    
    @IBOutlet weak var subSettingsTable: UITableView!
    @IBOutlet weak var categoriesTable: UITableView!
    
    @IBOutlet weak var drawSettingNameField: UITextField!
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var numberField: UITextField!
    
    @IBOutlet weak var minRarityLabelName: UILabel!
    @IBOutlet weak var minRarityLabel: UILabel!
    @IBOutlet weak var minRaritySlider: UISlider!
    
    
    @IBOutlet weak var maxRarityLabelName: UILabel!
    @IBOutlet weak var maxRarityLabel: UILabel!
    @IBOutlet weak var maxRaritySlider: UISlider!
    
    override func viewWillAppear(_ animated: Bool) {
        self.preferredContentSize = CGSize(width: 400, height: 400)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(_:)))
        
        self.numberField.delegate = self
        
        if setting == nil{
            let context = CoreDataStack.managedObjectContext
            setting = NSEntityDescription.insertNewObject(forEntityName: String(describing: DrawSetting.self), into: context) as? DrawSetting
        }
        
        numberLabel.text = "Liczba przedmiotów"
        minRarityLabelName.text = "Minimalna rzakdość"
        maxRarityLabelName.text = "Maksymalna rzakdość"
        
        minRarityLabel.text = rarityName.first
        maxRarityLabel.text = rarityName.last
        super.viewWillAppear(animated)
    }
    
    @IBAction func minRaritySliderChanged(_ sender: UISlider) {
        let rarity = Int(minRaritySlider.value.rounded(.toNearestOrEven))
        minRarityLabel.text = rarityName[rarity]
    }
    
    @IBAction func maxRaritySliderChanged(_ sender: UISlider) {
        let rarity = Int(maxRaritySlider.value.rounded(.toNearestOrEven))
        maxRarityLabel.text = rarityName[rarity]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == categoriesTable{
            return categories.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == categoriesTable{
            return (categories[section].subCategories?.count)! + 1
        }else{
            return (setting?.subSettings?.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == categoriesTable{
            return categories[section].name
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell?
        if tableView == categoriesTable{
            cell = tableView.dequeueReusableCell(withIdentifier: "categoriesCell")
            if indexPath.row == 0{
                cell?.textLabel?.text = "Cała Kategoria " + categories[indexPath.section].name!
            }else{
                let cellCategory = categories[indexPath.section]
                let cellSubCategories = cellCategory.subCategories?.sortedArray(using: [.sortSubCategoryByName]) as! [SubCategory]
                cell?.textLabel?.text = cellSubCategories[indexPath.row - 1].name
            }
            cell?.detailTextLabel?.font = UIFont.fontAwesome(ofSize: CGFloat(20))
            cell?.detailTextLabel?.text = String.fontAwesomeIcon(name: .send)
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "drawSubSettingCell")
            let subSetting = setting?.subSettings?.sortedArray(using: [NSSortDescriptor(key: #keyPath(DrawSubSetting.name), ascending: true)])[indexPath.row] as! DrawSubSetting
            
            let min = subSetting.minRarity > 0 ? "Min: " + rarityName[Int(subSetting.minRarity)] + " " : ""
            let max = subSetting.maxRarity < 3 ? "Max: " + rarityName[Int(subSetting.maxRarity)] + " " : ""
            
            if let subName = subSetting.name {
                cell?.textLabel?.text = subName
            }else{
                cell?.textLabel?.text = ""
            }
            
            cell?.detailTextLabel?.text = min + max + "Ilość: " + String(subSetting.itemsToDraw)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == categoriesTable{
            let context = CoreDataStack.managedObjectContext
            let subDraw = NSEntityDescription.insertNewObject(forEntityName: String(describing: DrawSubSetting.self), into: context) as! DrawSubSetting
            if indexPath.row == 0{
                subDraw.category = categories[indexPath.section]
                subDraw.name = subDraw.category?.name
            }else{
                subDraw.subCategory = categories[indexPath.section].subCategories?.sortedArray(using: [.sortSubCategoryByName])[indexPath.row - 1] as? SubCategory
                subDraw.name = subDraw.subCategory?.name
            }
            
            if !((numberField.text?.isEmpty)!){
                subDraw.itemsToDraw = Int64((numberField?.text)!)!
            }else{
                subDraw.itemsToDraw = 10
            }
            subDraw.minRarity = Int16(minRaritySlider.value.rounded(.toNearestOrEven))
            subDraw.maxRarity = Int16(maxRaritySlider.value.rounded(.toNearestOrEven))
            setting?.addToSubSettings(subDraw)
            subSettingsTable.reloadData()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    func done(_ sender: UIBarButtonItem){
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
