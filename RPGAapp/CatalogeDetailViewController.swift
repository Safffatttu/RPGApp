//
//  CatalogeDetailViewController.swift
//  RPGAapp
//
//  Created by Jakub on 09.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit

class catalogeDetail: UIViewController ,UITableViewDataSource, UITableViewDelegate {
    
    var currentSubCategory: String = ""
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return listOfItems.categories.count
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfItems.categories[section].1 - 1
        
    }
    
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return listOfItems.categories[section].0
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "")
        var cellAdress = Int()
        if (indexPath.section != 0){
            for i in 0...indexPath.section-1{
                cellAdress += (listOfItems.categories[i].1 - 1)
            }
        }
        cellAdress += indexPath.row
        
        cell?.textLabel?.text = listOfItems.items[cellAdress].name
        cell?.detailTextLabel?.text = listOfItems.items[cellAdress].subCategory
        return cell!
    }
    
    
}

