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
    
    override func viewDidLoad() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDrawSetting(_:)))
        
        let context = CoreDataStack.managedObjectContext
        let drawSettingsFetch: NSFetchRequest<DrawSetting> = DrawSetting.fetchRequest()
        drawSettingsFetch.sortDescriptors = [NSSortDescriptor(key: #keyPath(DrawSetting.name), ascending: true)]
        do{
            drawSettings = try context.fetch(drawSettingsFetch) as [DrawSetting]
        }
        catch{
            print("error")
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return  1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drawSettings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "randomItemCell")
        cell?.textLabel?.text = drawSettings[indexPath.row].name
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        drawQueue.async {
            self.drawItems(drawSetting: self.drawSettings[indexPath.row])
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .reloadRandomItemTable, object: nil)
            }
        }
    }
    
    func addDrawSetting(_ sender: UIBarButtonItem){
        let addDrawSettingControler = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "editDrawSetting")
        
        addDrawSettingControler.modalPresentationStyle = .pageSheet
        
        self.present(addDrawSettingControler, animated: true, completion: nil)
    }
    
    func drawItems(drawSetting: DrawSetting){
        if !(UserDefaults.standard.bool(forKey: "Dodawaj do listy wylosowanych")) {
            randomlySelected = []
        }
        
        let subSettings: [DrawSubSetting] = drawSetting.subSettings?.sortedArray(using: [NSSortDescriptor(key: #keyPath(DrawSubSetting.name), ascending: true)]) as! [DrawSubSetting]
        
        for setting in subSettings{
            var itemsToDraw: [Item] = []
            let context = CoreDataStack.managedObjectContext
            let weight: Int64

            let numberOf = Int(setting.itemsToDraw)
            
            if(setting.category != nil){
                itemsToDraw = setting.category?.items?.sortedArray(using: [NSSortDescriptor(key: #keyPath(Item.name), ascending: true)]) as! [Item]
            }
            else if(setting.subCategory != nil) {
                itemsToDraw = setting.subCategory?.items?.sortedArray(using: [NSSortDescriptor(key: #keyPath(Item.name), ascending: true)]) as! [Item]
            }else{
                let itemFetch: NSFetchRequest<Item> = Item.fetchRequest()
                do{
                    itemsToDraw = try context.fetch(itemFetch)
                }
                catch let error as NSError{
                    print(error)
                }
            }

            itemsToDraw = itemsToDraw.map{
                $0.propability = Int64(propabilities[Int(Int(($0).rarity) - 1)])
                return $0
            }

            weight = Int64(itemsToDraw.map{$0.propability}.reduce(0,+))
            
            for _ in 1...numberOf{
                let newItem = drawItem(items: itemsToDraw, weightTotal: weight)
                var itemHandler = randomlySelected.filter({$0.item == newItem}).first
                
                itemHandler?.count += 1
        
                if itemHandler == nil{
                    itemHandler = NSEntityDescription.insertNewObject(forEntityName: String(describing: ItemHandler.self), into: context) as! ItemHandler
                    itemHandler?.item = newItem
                    randomlySelected.append(itemHandler!)
                }
            }
        CoreDataStack.saveContext()
        }
        return
    }
    
    func drawItem(items: [Item],weightTotal: Int64) -> Item{
        return weightedRandom(items: items,weightTotal: weightTotal)
    }
    
}

extension Notification.Name{
    static let reloadRandomItemTable = Notification.Name("reloadRandomItemTable")
}
