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
var randomlySelected = [Item]()
class randomItemMenu: UITableViewController {
    
    fileprivate let drawQueue = DispatchQueue(label: "com.SS.RPGAapp")
    
    var drawSettings: [DrawSetting] = []
    
    override func viewDidLoad() {
        let context = CoreDataStack.managedObjectContext
        let drawSettingsFetch: NSFetchRequest<DrawSetting> = DrawSetting.fetchRequest()
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
            self.drawItems(drawSetting: self.drawSettings.first!)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .reloadRandomItemTable, object: nil)
            }
        }
    }
    
    func drawItems(drawSetting: DrawSetting){
        let subSettings: [DrawSubSetting] = drawSetting.subSettings?.sortedArray(using: [NSSortDescriptor(key: #keyPath(DrawSubSetting.name), ascending: true)]) as! [DrawSubSetting]
        
        for setting in subSettings{
            var itemsToDraw: [Item]
            let weight: Int
            
            let numberOf = Int(setting.itemsToDraw)
            
            if(setting.category != nil){
                itemsToDraw = setting.category?.items?.sortedArray(using: [NSSortDescriptor(key: #keyPath(Item.name), ascending: true)]) as! [Item]
            }
            else{
                itemsToDraw = setting.subCategory?.items?.sortedArray(using: [NSSortDescriptor(key: #keyPath(Item.name), ascending: true)]) as! [Item]
            }
            
            itemsToDraw = itemsToDraw.map{
                $0.propability = propabilities[Int(Int(($0).rarity) - 1)]
                return $0
            }
            
            weight = Int (itemsToDraw.map{$0.propability}.reduce(0, +))
            print(numberOf)
            
            for _ in 1...numberOf{
                let newItem = drawItem(items: itemsToDraw, weightTotal: weight)
                randomlySelected.append(newItem)
            }
        }
        
        CoreDataStack.saveContext()
        return
    }
    
    func drawItem(items: [Item],weightTotal: Int) -> Item{
        return weightedRandom(items: items,weightTotal: weightTotal)
    }
    
}
extension Notification.Name{
    static let reloadRandomItemTable = Notification.Name("reloadRandomItemTable")
}


enum drawType: Int{
    case category
    case subCategory
}
