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
    var rarity: Int?
    var quantity: Int?
    var measure: String?
}

struct itemList{
    var items:  [item]
    var exRate: Double
    var currecny: String?
    var categories: [(String,Int,[(String,Int)])]
}



var listOfItems = loadItemList(data: loadStringTableFromDataAsset(Data: "ITEMS"))


class ItemMenu: UITableViewController {
    
    let itemMenuItems = [("Cataloge","showCatalogeView"),("RandomItem","showRandomItem"),("Handlarze","showHandlarze")]
    

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
        let toGo = IndexPath.init(row: myRand(10),section: section!)
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
        if segue.identifier == "showCatalogeDetailView"{
            let controller = (segue.destination as! UINavigationController).topViewController as! catalogeDetail
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: itemMenuItems[indexPath.row].1, sender: self)
        if (indexPath.row == 0){
            self.performSegue(withIdentifier: "showCatalogeDetailView", sender: self)
        }
    }
    
    
    
    
    
    
    
    
    
    
}
