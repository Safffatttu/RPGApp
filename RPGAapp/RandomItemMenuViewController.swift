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
    
    var drawSettings: [DrawSetting] = []
    var subCategories: [SubCategory] = []
    
    override func viewDidLoad() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDrawSetting(_:)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDrawSettings), name: .reloadDrawSettings, object: nil)
        
        let context = CoreDataStack.managedObjectContext
        let drawSettingsFetch: NSFetchRequest<DrawSetting> = DrawSetting.fetchRequest()
        let subCategoryFetch: NSFetchRequest<SubCategory> = SubCategory.fetchRequest()
        
        drawSettingsFetch.sortDescriptors = [NSSortDescriptor(key: #keyPath(DrawSetting.name), ascending: true)]
        do{
            drawSettings = try context.fetch(drawSettingsFetch) as [DrawSetting]
        }
        catch{
            print("error")
        }
        
        subCategoryFetch.sortDescriptors = [sortSubCategoryByCategory,sortSubCategoryByName]
        
        do{
            subCategories = try context.fetch(subCategoryFetch)
        }
        catch{
            print("error fetching")
        }
    }
    
    func reloadDrawSettings(){
        let context = CoreDataStack.managedObjectContext
        let drawSettingsFetch: NSFetchRequest<DrawSetting> = DrawSetting.fetchRequest()

        drawSettingsFetch.sortDescriptors = [NSSortDescriptor(key: #keyPath(DrawSetting.name), ascending: true)]
        do{
            drawSettings = try context.fetch(drawSettingsFetch) as [DrawSetting]
        }
        catch{
            print("error")
        }
        
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return  2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return drawSettings.count
        }
        return subCategories.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Własne losowania"
        }
        return "Domyślne"
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 100
        }
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "customSettingCell") as! customSettingCell
            cell.nameLabel?.text = drawSettings[indexPath.row].name
            cell.drawSetting = drawSettings[indexPath.row]
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "randomItemCell")
        cell?.textLabel?.text = subCategories[indexPath.row].name
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        drawQueue.async {
            var setting: DrawSetting?
            var subCategory: SubCategory?
            if indexPath.section == 0{
                setting = self.drawSettings[indexPath.row]
            }else{
                subCategory = self.subCategories[indexPath.row]
            }

            self.drawItems(drawSetting: setting, subCategory: subCategory )
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .reloadRandomItemTable, object: nil)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            CoreDataStack.managedObjectContext.delete(drawSettings[indexPath.row])
            drawSettings.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            viewDidLoad()
        }
    }
    
    func addDrawSetting(_ sender: UIBarButtonItem){
        let addDrawSettingControler = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "settingEditor")
        
        addDrawSettingControler.modalPresentationStyle = .pageSheet
        
        self.present(addDrawSettingControler, animated: true, completion: nil)
    }
    
    func drawItems(drawSetting: DrawSetting?, subCategory: SubCategory?){
        var itemsToDraw: [Item] = []
        
        if !(UserDefaults.standard.bool(forKey: "Dodawaj do listy wylosowanych")) {
            randomlySelected = []
        }
        
        if subCategory != nil{
            itemsToDraw = subCategory?.items?.sortedArray(using: [sortItemByName]) as! [Item]
            drawItemHandler(items: itemsToDraw, numberOf: 10)
            CoreDataStack.saveContext()
            return
        }
        
        let subSettings: [DrawSubSetting] = (drawSetting?.subSettings?.sortedArray(using: [NSSortDescriptor(key: #keyPath(DrawSubSetting.name), ascending: true)]) as? [DrawSubSetting])!
        
        for setting in subSettings{
            
            let context = CoreDataStack.managedObjectContext
            
            let numberOf = Int(setting.itemsToDraw)
            
            if(setting.category != nil){
                itemsToDraw = setting.category?.items?.sortedArray(using: [sortItemByName]) as! [Item]
            }
            else if(setting.subCategory != nil){
                itemsToDraw = setting.subCategory?.items?.sortedArray(using: [sortItemByName]) as! [Item]
            }
            else if((setting.items?.count)! > 0){
                itemsToDraw = setting.items?.sortedArray(using: [sortItemByName]) as! [Item]
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

            drawItemHandler(items: itemsToDraw,numberOf: numberOf)
            
        CoreDataStack.saveContext()
        }
        return
    }
    
    func drawItemHandler(items: [Item],numberOf: Int){
        let weight: Int64
        var itemsToDraw = items
        
        itemsToDraw = items.map{
            $0.propability = Int64(propabilities[Int(Int(($0).rarity) - 1)])
            return $0
        }
        
        weight = Int64(itemsToDraw.map{$0.propability}.reduce(0,+))
        
        for _ in 1...numberOf{
            let newItem = drawItem(items: itemsToDraw, weightTotal: weight)
            var itemHandler = randomlySelected.filter({$0.item == newItem}).first
            
            itemHandler?.count += 1
            
            if itemHandler == nil{
                itemHandler = (NSEntityDescription.insertNewObject(forEntityName: String(describing: ItemHandler.self), into: CoreDataStack.managedObjectContext) as! ItemHandler)
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
}
