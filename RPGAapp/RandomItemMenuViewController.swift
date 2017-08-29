//
//  RandomItemMenuViewController.swift
//  RPGAapp
//
//  Created by Jakub on 12.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit

var randomlySelected = [item]()
class randomItemMenu: UITableViewController {
    
    fileprivate let drawQueue = DispatchQueue(label: "com.SS.RPGAapp")
    
    
    let losowania = [("Broń", drawType.category,"BROŃ",10000), ("Broń biała", drawType.subCategory,"BIAŁA",2)]
    
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
            print("asd")
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .reloadRandomItemTable, object: nil)
                print("dd")
            }
        }
    }
    
    func drawItems(type: drawType, range: String, numberOf: Int){
        if !(settingValues["Dodawaj do listy wylosowanych"]!) {
            randomlySelected = []
        }
        //print(listOfItems.items.filter({$0.category == range}).filter({$0.rarity! > 4}))
        //print(NSSet(array: listOfItems.items.filter({$0.category == "BROŃ"}).map({$0.quantity})))
        let itemsToDraw: [item]
        switch type{
            case .category:
                itemsToDraw = listOfItems.items.filter({$0.category == range})

            case .subCategory:
                itemsToDraw = listOfItems.items.filter({$0.subCategory == range})
            }
        
        let weightTotal = UInt(itemsToDraw.map{$0.rarity!}.reduce(0, +))
        for _ in 1...numberOf{
            let newItem = drawItem(items: itemsToDraw, weightTotal: weightTotal)
            //randomlySelected.append(listOfItems.items.index{$0.name == newItem.name}!)
            randomlySelected.append(newItem)
        }
        return
    }
    
    func drawItem(items: [item],weightTotal: UInt) -> item{
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
