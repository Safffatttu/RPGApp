//
//  ItemsMenuViewController.swift
//  characterGen1
//
//  Created by Jakub on 06.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit

struct item{
    var name: String
    var category : String
    var subCategory: String
    var description: String?
    var price : Double?
    var rarity: UInt?
    var quantity: Int?
    var measure: String?
    
    static func archive(w:item) -> Data {
        var fw = w
        return Data(bytes: &fw, count: MemoryLayout<item>.stride)
    }
    
    static func unarchive(d:Data) -> item {
        /*guard d.count == MemoryLayout<item>.stride else {
            fatalError("BOOM!")
        }*/
        
        var w:item?
        d.withUnsafeBytes({(bytes: UnsafePointer<item>)->Void in
            w = UnsafePointer<item>(bytes).pointee
        })
        return w!
    }

    
    
}

struct itemList{
    var items:  [item]
    var currency: [(String,Double)]
    var categories: [(String,Int,[(String,Int)])]
}



var listOfItems = loadItemList(data: loadStringTableFromDataAsset(Data: "ITEMS"))


class ItemMenu: UITableViewController {
    
    let itemMenuItems = [("Cataloge","showCatalogeView","showCatalogeDetailView"),("RandomItem","showRandomItemView","showRandomItemDetailView"),("Handlarze","showHandlarzeView","showHandlarzeDetailView")]
    

    override func viewDidLoad() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(showRandom(_:)))
    }
    
    func showRandom(_ sender: UIBarButtonItem) {
        //let index = IndexPath(row: 10,section: 1)
        //let toGo = IndexPath.init(row: myRand((listOfItems.categories.first?.1)! - 1 ), section: 0)
        var section: Int?  = (tableView.indexPathsForVisibleRows?.first?.section)
        if(section == nil){
            section = 0
        }
        let toGo = IndexPath.init(row: myRand(itemMenuItems.count - 1),section: section!)
        tableView.scrollToRow(at: toGo, at: UITableViewScrollPosition.top, animated: true)
        return
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemMenuItems.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuItemCell")
        cell?.textLabel?.text = itemMenuItems[indexPath.row].0
        if indexPath.row == 0{
            cell?.accessoryType = .disclosureIndicator
            
        }
        return cell!
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.identifier)
        print(segue.description)
        //print(navigationController?.topViewController)
        if segue.identifier == "showCatalogeDetailView"{
            let controller = (segue.destination as! UINavigationController).topViewController as! catalogeDetail
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        if segue.identifier == "showRandomItemDetailView"{
            print(segue.destination)
            let controller = (segue.destination as! UINavigationController).topViewController as! randomItemDetailView
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        if segue.identifier == "showHandlarzeDetailView"{
            print(segue.destination)
            let controller = (segue.destination as! UINavigationController).topViewController as! handlarzeDetailView
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: itemMenuItems[indexPath.row].1, sender: self)
        self.performSegue(withIdentifier: itemMenuItems[indexPath.row].2, sender: self)
        
        /*if (indexPath.row == 0){
            self.performSegue(withIdentifier: "showCatalogeDetailView", sender: self)
        }*/
        
    }
    
    
    
    
    
    
    
    
    
    
}
