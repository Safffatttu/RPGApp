//
//  Items.swift
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

//var itemList: ([item],)
var listOfItems = loadItemList(data: loadStringTableFromDataAsset(Data: "ITEMS"))

class ItemsView: UITableViewController {
    
  
    override func viewDidLoad() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(showRandomItem(_:)))
    }
    
    
    func showRandomItem(_ sender: UIBarButtonItem) {
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
    /*
    tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:10 inSection:indexPath.section]
    atScrollPosition:UITableViewScrollPositionMiddle animated:NO
    */
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return listOfItems.categories.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfItems.categories[section].1 - 1
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return listOfItems.categories[section].0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell")
        var cellAdress = Int()
        if (indexPath.section != 0){
            for i in 0...indexPath.section-1{
                cellAdress += (listOfItems.categories[i].1 - 1)
            }
        }
        cellAdress += indexPath.row
        print(listOfItems.items[cellAdress].name)
        cell?.textLabel?.text = listOfItems.items[cellAdress].name
        cell?.detailTextLabel?.text = listOfItems.items[cellAdress].subCategory
        return cell!
    }
    
    
    
}
