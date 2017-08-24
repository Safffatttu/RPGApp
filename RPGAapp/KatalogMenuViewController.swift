//
//  KatalogMenuViewController.swift
//  RPGAapp
//
//  Created by Jakub on 09.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit

var goToLocation =  Int()

class catalogeMenu: UITableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return listOfItems.categories.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let subCategoriesInSection = NSSet(array: listOfItems.items.filter({$0.category == listOfItems.categories[section].0}).map({$0.subCategory}))
        return subCategoriesInSection.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catalogeMenuCell")
        cell?.textLabel?.text = listOfItems.categories[indexPath.section].2[indexPath.row].0.capitalized
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return listOfItems.categories[section].0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToLocation = 0
        if indexPath.section > 0{
            for i in 0...indexPath.section - 1{
                goToLocation += NSSet(array: listOfItems.items.filter({$0.category == listOfItems.categories[i].0}).map({$0.subCategory})).count
            }
        }
        goToLocation += indexPath.row
        NotificationCenter.default.post(name: .goToSectionCataloge, object: nil)
    }
    
}
extension Notification.Name{
    static let goToSectionCataloge = Notification.Name("goToSectionCataloge")
}

