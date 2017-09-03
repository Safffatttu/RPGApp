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
    
    
    let losowania = [("Broń", drawType.category,"BROŃ",100000), ("Broń biała", drawType.subCategory,"BIAŁA",2)]
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return  1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return losowania.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "randomItemCell")
        cell?.textLabel?.text = losowania[indexPath.row].0
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        drawQueue.async {
            self.drawItems(type: self.losowania[indexPath.row].1, range: self.losowania[indexPath.row].2, numberOf: self.losowania[indexPath.row].3)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .reloadRandomItemTable, object: nil)
            }
        }
    }
    
    func drawItems(type: drawType, range: String, numberOf: Int){
        if !(UserDefaults.standard.bool(forKey: "Dodawaj do listy wylosowanych")) {
            randomlySelected = []
        }

        //let fetch =  NSFetchRequest<Item>(entityName: "Item")
        var itemsToDraw: [Item] = []
        let sortByName = NSSortDescriptor(key: #keyPath(Item.name), ascending: true)
        let sortBySubCategory = NSSortDescriptor(key: #keyPath(Item.subCategory), ascending: true)
        let context = CoreDataStack.managedObjectContext
        
        switch type{
            case .category:
                let fetchRequest = NSFetchRequest<Category>(entityName: NSStringFromClass(Category))
                fetchRequest.predicate = NSPredicate(format: "name == %@", range)
                do{
                    itemsToDraw = try (context.fetch(fetchRequest).first as! Category).items?.sortedArray(using: [sortByName]) as! [Item]
                    //itemsToDraw = try (CoreDataStack.managedObjectContext.fetch(fetch).first!).items?.sortedArray(using: [sortByName,sortBySubCategory]) as! [Item]
                }
                catch{
                    print("Error")
                }
            
            case .subCategory:
                let fetchRequest = NSFetchRequest<SubCategory>(entityName: NSStringFromClass(SubCategory))
                fetchRequest.predicate = NSPredicate(format: "name == %@", range)
                do{
                    itemsToDraw = try (context.fetch(fetchRequest).first as! Category).items?.sortedArray(using: [sortByName]) as! [Item]
                    //itemsToDraw = try (CoreDataStack.managedObjectContext.fetch(fetch).first!).items?.sortedArray(using: [sortByName,sortBySubCategory]) as! [Item]
                }
                catch{
                    print("Error")
                }
        }
 
        /*do{
            itemsToDraw = try CoreDataStack.managedObjectContext.fetch(fetch)
        }
        catch{
            print("Error")
        }*/
      
        print(itemsToDraw)
        itemsToDraw = itemsToDraw.map{
            $0.rarity = propabilities[Int(Int(($0 as! Item).rarity) - 1)]
            return $0
        }
        
        //let weightTotal = Int((itemsToDraw as! [(Item,UInt)]).map{$0.1}.reduce(0, +))
        let weightTotal = Int (itemsToDraw.map{$0.rarity}.reduce(0, +))
        for _ in 1...numberOf{
            let newItem = drawItem(items: itemsToDraw, weightTotal: weightTotal)
            randomlySelected.append(newItem)
        }
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
