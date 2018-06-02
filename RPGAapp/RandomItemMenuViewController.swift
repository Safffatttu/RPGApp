//
//  RandomItemMenuViewController.swift
//  RPGAapp
//
//  Created by Jakub on 12.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let propabilities: [Int16] = [100,800,90,9,1]
var randomlySelected = [ItemHandler]()

class randomItemMenu: UITableViewController {
    
    fileprivate let drawQueue = DispatchQueue(label: "com.SS.RPGAapp")
    
    var drawSettings: [DrawSetting] = Load.drawSettings()
    var subCategories: [SubCategory] = Load.subCategories()
    var categories: [Category] = Load.categories()
    var lastDrawSetting: Any?
    override func viewDidLoad() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDrawSetting(_:)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDrawSettings), name: .reloadDrawSettings, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reDrawAllItems), name: .reDrawAllItems, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reDrawItem(_:)), name: .reDrawItem, object: nil)
        
        self.tableView.accessibilityIdentifier = "randomItemMenu"
    }
    
    func reloadDrawSettings(){
        drawSettings = Load.drawSettings()
        
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if drawSettings.count > 0{
            return categories.count + 2
        }else{
            return categories.count + 1
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if drawSettings.count > 0{
            if section == 0{
                return drawSettings.count
            }else if section == 1{
                return 1
            }
            return (categories[section - 2].subCategories?.count)! + 1
        }else {
            if section == 0{
                return 1
            }
            return (categories[section - 1].subCategories?.count)! + 1
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if drawSettings.count > 0{
            if section == 0{
                return "Własne losowania"
            }else if section == 1{
                return "Wszystkie przedmioty"
            }else{
                return categories[section-2].name
            }
        }else if section == 0{
            return "Wszystkie przedmioty"
        }else{
            return categories[section-1].name
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if  indexPath.section == 0 && drawSettings.count > 0{
            return CGFloat((drawSettings[indexPath.row].subSettings?.count)! * 30 + 25)
        }else{
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section: Int
        if drawSettings.count > 0{
            section = indexPath.section - 2
        }else{
            section = indexPath.section - 1
        }

        if indexPath.section == 0 && drawSettings.count > 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "customSettingCell") as! customSettingCell
            cell.nameLabel?.text = drawSettings[indexPath.row].name
            cell.drawSetting = drawSettings[indexPath.row]
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "randomItemCell")
        let cellName: String
        
        if section == -1{
            cell?.textLabel?.text = "Wszystkie przedmioty"
            return cell!
        }
        
        if indexPath.row == 0{
            cellName = "Cała kategoria " + categories[section].name!
            cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: (cell?.textLabel?.font.pointSize)!)
        }else{
            cell?.textLabel?.font = UIFont.systemFont(ofSize: (cell?.textLabel?.font.pointSize)!)
            cellName = (categories[section].subCategories?.sortedArray(using: [.sortSubCategoryByName])[indexPath.row - 1] as! SubCategory).name!
        }
        
        cell?.textLabel?.text = cellName
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        drawQueue.async {
            var setting: DrawSetting?
            var subCategory: SubCategory?
            var category: Category?
            let section: Int
            
            if self.drawSettings.count > 0{
                section = indexPath.section - 2
            }else{
                section = indexPath.section - 1
            }
            
            if indexPath.section == 0 && self.drawSettings.count > 0{
                setting = self.drawSettings[indexPath.row]
                self.lastDrawSetting = setting
            }else if indexPath.row == 0 && section != -1{
                category = self.categories[section]
                self.lastDrawSetting = category
            }else if section != -1{
                subCategory = self.categories[section].subCategories?.sortedArray(using: [.sortSubCategoryByName])[indexPath.row - 1] as? SubCategory
                self.lastDrawSetting = subCategory
            }
            
            self.drawItems(drawSetting: setting, subCategory: subCategory, category: category, reDraw: .not)
//            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .reloadRandomItemTable, object: nil)
//            }
//        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 && drawSettings.count > 0
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: "Edytuj") { (action, path) in
            let edditDraw = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "settingEditor") as! UINavigationController
            
            edditDraw.modalPresentationStyle = .pageSheet
            
            (edditDraw.viewControllers.first as! EditDrawSetting).setting = self.drawSettings[indexPath.row]
            (edditDraw.viewControllers.first as! EditDrawSetting).editingMode = true
            (edditDraw.viewControllers.first as! EditDrawSetting).title = "Edytor ustawień"
            self.present(edditDraw, animated: true, completion: nil)
        }
        editAction.backgroundColor = .blue
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "Usuń") { (rowAction, indexPath) in
            CoreDataStack.managedObjectContext.delete(self.drawSettings[indexPath.row])
            self.drawSettings.remove(at: indexPath.row)
            CoreDataStack.saveContext()
            
            if self.drawSettings.count == 0{
                let index = IndexSet(integer: 0)
                tableView.deleteSections(index, with: .automatic)
            }else{
                let index = IndexPath(row: indexPath.row, section: 0)
                tableView.deleteRows(at: [index], with: .automatic)
            }
        }
        deleteAction.backgroundColor = .red
        
        return [deleteAction,editAction]
    }
    
    func reDrawAllItems(){
//        drawQueue.async {
            guard self.lastDrawSetting != nil else{
                return
            }
            let setting = self.lastDrawSetting as? DrawSetting
            let subCategory = self.lastDrawSetting as? SubCategory
            let category = self.lastDrawSetting as? Category
            self.drawItems(drawSetting: setting, subCategory: subCategory, category: category,reDraw: .all)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .reloadRandomItemTable, object: nil)
            }
//        }
    }
    
    func reDrawItem(_ notification: NSNotification){
        let object =  notification.object as! (ItemHandler,IndexPath)
        let handler = object.0
        var index: IndexPath? = object.1

        let originalCount = Int(handler.count)

        if let drawSetting = self.lastDrawSetting as? DrawSetting{
            var itemsToDraw: [Item] = []
            
            let subSettings: [DrawSubSetting] = (drawSetting.subSettings?.sortedArray(using: [NSSortDescriptor(key: #keyPath(DrawSubSetting.name), ascending: true)]) as? [DrawSubSetting])!
            
            for setting in subSettings{
                let context = CoreDataStack.managedObjectContext
                var subItems: [Item] = []
                if(setting.category != nil){
                    subItems = setting.category?.items?.sortedArray(using: [.sortItemByName]) as! [Item]
                }
                else if(setting.subCategory != nil){
                    subItems = setting.subCategory?.items?.sortedArray(using: [.sortItemByName]) as! [Item]
                }
                else if((setting.items?.count)! > 0){
                    subItems = setting.items?.sortedArray(using: [.sortItemByName]) as! [Item]
                }
                else{
                    let itemFetch: NSFetchRequest<Item> = Item.fetchRequest()
                    do{
                        subItems = try context.fetch(itemFetch)
                    }
                    catch let error as NSError{
                        print(error)
                    }
                }
                subItems = subItems.filter({$0.rarity >= setting.minRarity && $0.rarity <= setting.maxRarity})
                
                itemsToDraw.append(contentsOf: subItems)
            }
            
            self.drawItemHandler(items: itemsToDraw, numberOf: originalCount)
        }
        
        else if let subCategory = self.lastDrawSetting as? SubCategory{
            let itemsToDraw = subCategory.items?.sortedArray(using: [.sortItemByName]) as! [Item]
            self.drawItemHandler(items: itemsToDraw , numberOf: originalCount)
        }
        
        else if let category = self.lastDrawSetting as? Category{
            let itemsToDraw = category.items?.sortedArray(using: [.sortItemByName]) as! [Item]
            self.drawItemHandler(items: itemsToDraw , numberOf: originalCount)
            
        }else{
            let context = CoreDataStack.managedObjectContext
            var itemsToDraw: [Item] = []
            let itemFetch: NSFetchRequest<Item> = Item.fetchRequest()
            
            do{
                itemsToDraw = try context.fetch(itemFetch)
            }
            catch let error as NSError{
                print(error)
            }
                            
            self.drawItemHandler(items: itemsToDraw, numberOf: originalCount)
        }

        if randomlySelected[(index?.row)!].count - Int64(originalCount) == 0{
            randomlySelected.remove(at: (index?.row)!)
            
        }else{
            randomlySelected[(index?.row)!].count = randomlySelected[(index?.row)!].count - Int64(originalCount)
        }

        CoreDataStack.saveContext()

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .reloadRandomItemTable, object: nil)
        }
    }
    
    func addDrawSetting(_ sender: UIBarButtonItem){
        let addDrawSettingControler = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "settingEditor")
        
        addDrawSettingControler.modalPresentationStyle = .pageSheet
        
        self.present(addDrawSettingControler, animated: true, completion: nil)
    }
    
    func drawItems(drawSetting: DrawSetting?, subCategory: SubCategory?, category: Category?, reDraw: reDraw){
        var itemsToDraw: [Item] = []
        
        if !(UserDefaults.standard.bool(forKey: "Dodawaj do listy wylosowanych")) && reDraw != .single {
            randomlySelected = []
        }
        var numberOf: Int
        if reDraw == .single{
            numberOf = 1
        }else{
            numberOf = 10
        }
        
        if subCategory != nil{
            itemsToDraw = subCategory?.items?.sortedArray(using: [.sortItemByName]) as! [Item]
            drawItemHandler(items: itemsToDraw, numberOf: numberOf)
            CoreDataStack.saveContext()
            return
        }else if category != nil{
            itemsToDraw = category?.items?.sortedArray(using: [.sortItemByName]) as! [Item]
            drawItemHandler(items: itemsToDraw, numberOf: numberOf)
            CoreDataStack.saveContext()
            return
        }else if drawSetting == nil{
            let context = CoreDataStack.managedObjectContext
            let itemFetch: NSFetchRequest<Item> = Item.fetchRequest()
            
            do{
                itemsToDraw = try context.fetch(itemFetch)
            }
            catch let error as NSError{
                print(error)
            }
            
            drawItemHandler(items: itemsToDraw, numberOf: numberOf)
            
            CoreDataStack.saveContext()
            return
        }
        
        let subSettings: [DrawSubSetting] = (drawSetting?.subSettings?.sortedArray(using: [NSSortDescriptor(key: #keyPath(DrawSubSetting.name), ascending: true)]) as? [DrawSubSetting])!
        
        for setting in subSettings{
            
            let context = CoreDataStack.managedObjectContext
            
            if reDraw == .single{
                numberOf = 1
            }else{
                numberOf = Int(setting.itemsToDraw)
            }
            
            if(setting.category != nil){
                itemsToDraw = setting.category?.items?.sortedArray(using: [.sortItemByName]) as! [Item]
            }
            else if(setting.subCategory != nil){
                itemsToDraw = setting.subCategory?.items?.sortedArray(using: [.sortItemByName]) as! [Item]
            }
            else if((setting.items?.count)! > 0){
                itemsToDraw = setting.items?.sortedArray(using: [.sortItemByName]) as! [Item]
            }
            else{
                let itemFetch: NSFetchRequest<Item> = Item.fetchRequest()
                do{
                    itemsToDraw = try context.fetch(itemFetch)
                }
                catch let error as NSError{
                    print(error)
                }
            }

            itemsToDraw = itemsToDraw.filter({$0.rarity >= setting.minRarity && $0.rarity <= setting.maxRarity})
            
            if itemsToDraw.count == 0{
                continue
            }
            
            drawItemHandler(items: itemsToDraw,numberOf: numberOf)
            
            CoreDataStack.saveContext()
            
            if reDraw == .single {
                break
            }
        }
        return
    }
    
    func drawItemHandler(items: [Item],numberOf: Int){
        let weight: Int64
        var itemsToDraw = items
        
        itemsToDraw = items.map{
            $0.propability = Int64(propabilities[Int($0.rarity) - 1])
            return $0
        }
        
        weight = Int64(itemsToDraw.map{$0.propability}.reduce(0,+))
        
        for _ in 1...numberOf{
            let newItem = drawItem(items: itemsToDraw, weightTotal: weight)
            var itemHandler = randomlySelected.filter({$0.item == newItem}).first
            
            itemHandler?.count += 1
            
            if itemHandler == nil{
                let context = CoreDataStack.managedObjectContext
                itemHandler = (NSEntityDescription.insertNewObject(forEntityName: String(describing: ItemHandler.self), into: context) as! ItemHandler)
                itemHandler?.item = newItem
                randomlySelected.append(itemHandler!)
            }
        }
    }
    
    func drawItem(items: [Item],weightTotal: Int64) -> Item{
        return weightedRandom(items: items,weightTotal: weightTotal)
    }
}

class customSettingCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var subSettingTable: UITableView!
    
    var drawSetting: DrawSetting? = nil
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (drawSetting?.subSettings?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subSettingCell")
        let cellDrawSubSetting = (drawSetting?.subSettings?.sortedArray(using: [NSSortDescriptor(key: #keyPath(DrawSubSetting.name), ascending: true)])[indexPath.row] as! DrawSubSetting)

        cell?.textLabel?.text = cellDrawSubSetting.name
        cell?.detailTextLabel?.text = String(cellDrawSubSetting.itemsToDraw)
        
        return cell!
    }
}

extension Notification.Name{
    static let reloadRandomItemTable = Notification.Name("reloadRandomItemTable")
    static let reloadDrawSettings = Notification.Name("reloadDrawSettings")
    static let reDrawAllItems = Notification.Name("reDrawAllItems")
    static let reDrawItem = Notification.Name("reDrawItem")
}

enum reDraw {
    case all
    case single
    case not
}

