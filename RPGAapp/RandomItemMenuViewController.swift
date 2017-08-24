//
//  RandomItemMenuViewController.swift
//  RPGAapp
//
//  Created by Jakub on 12.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit

var randomlySelected = [Int]()
class randomItemMenu: UITableViewController {
    
    let losowania = [("Broń", drawType.category,"BROŃ",2), ("Broń biała", drawType.subCategory,"BIAŁA",2)]
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
        drawItems(type: losowania[indexPath.row].1, range: losowania[indexPath.row].2, numberOf: losowania[indexPath.row].3)
        //print (listOfItems.items.filter({$0.category == losowania[indexPath.row].2}))
    }
    
    func drawItems(type: drawType, range: String, numberOf: Int){
        if !(settingValues["Dodawaj do listy wylosowanych"]!) {
            randomlySelected = []
        }
        for _ in 1...numberOf{
            var newItem: item
            switch type{
                case .category:
                    newItem = drawItem(items: listOfItems.items.filter({$0.category == range}))
                case .subCategory:
                    newItem = drawItem(items: listOfItems.items.filter({$0.subCategory == range}))
            }
            randomlySelected.append(listOfItems.items.index{$0.name == newItem.name}!)
        }
        NotificationCenter.default.post(name: .reloadRandomItemTable, object: nil)
        return
    }
    
    func drawItem(items: [item]) -> item{
        let weightedMap = items.map({($0,UInt($0.quantity!))})
        print(weightedMap)
        return weightedRandomElement(items: weightedMap)
    }
    
}
extension Notification.Name{
    static let reloadRandomItemTable = Notification.Name("reloadRandomItemTable")
}


enum drawType: Int{
    case category
    case subCategory
}
