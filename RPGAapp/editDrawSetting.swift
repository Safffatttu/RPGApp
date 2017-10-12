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

class editDrawSetting: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate{
    
    var setting: DrawSetting? = nil
    
    //var categories: [Category] = []
    var subCategories: [SubCategory] = []
    
    //let categoryFetch: NSFetchRequest<Category> = Category.fetchRequest()
    let subCategoryFetch: NSFetchRequest<SubCategory> = SubCategory.fetchRequest()
    
    let context = CoreDataStack.managedObjectContext
    
    @IBOutlet weak var subSettingsTable: UITableView!
    @IBOutlet weak var categoriesTable: UITableView!
    
    @IBOutlet weak var numberField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        self.preferredContentSize = CGSize(width: 400, height: 400)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissView(_:)))
        
        self.numberField.delegate = self
        
        let subCategoryFetch: NSFetchRequest<SubCategory> = SubCategory.fetchRequest()
        
        subCategoryFetch.sortDescriptors = [sortSubCategoryByCategory,sortSubCategoryByName]
        
        do{
            subCategories = try context.fetch(subCategoryFetch)
        }
        catch{
            print("error fetching")
        }
        
        if setting == nil{
            let context = CoreDataStack.managedObjectContext
            setting = NSEntityDescription.insertNewObject(forEntityName: String(describing: DrawSetting.self), into: context) as? DrawSetting
        }
        
        super.viewWillAppear(animated)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == categoriesTable{
            return subCategories.count// + categories.count
        }else{
            return (setting?.subSettings?.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell?
        if tableView == categoriesTable{
            cell = tableView.dequeueReusableCell(withIdentifier: "categoriesCell")
            cell?.textLabel?.text = subCategories[indexPath.row].name
            cell?.detailTextLabel?.font = UIFont.fontAwesome(ofSize: CGFloat(20))
            cell?.detailTextLabel?.text = String.fontAwesomeIcon(name: .send)
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "drawSubSettingCell")
            let subSetting = setting?.subSettings?.sortedArray(using: [NSSortDescriptor(key: #keyPath(DrawSubSetting.name), ascending: true)])[indexPath.row] as! DrawSubSetting
            cell?.textLabel?.text = subSetting.name
            cell?.detailTextLabel?.text = String(subSetting.itemsToDraw)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == categoriesTable{
            let subDraw = NSEntityDescription.insertNewObject(forEntityName: String(describing: DrawSubSetting.self), into: context) as! DrawSubSetting
            subDraw.subCategory = subCategories[indexPath.row]
            subDraw.name = subCategories[indexPath.row].name
            if !((numberField.text?.isEmpty)!){
                subDraw.itemsToDraw = Int64((numberField?.text)!)!
            }else{
                subDraw.itemsToDraw = 10
            }
            
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
        setting?.name = "Własne losowanie"
        CoreDataStack.saveContext()
        NotificationCenter.default.post(name: .reloadDrawSettings, object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    func dismissView(_ sender: UIBarButtonItem){
        dismiss(animated: true, completion: nil)
    }
}
