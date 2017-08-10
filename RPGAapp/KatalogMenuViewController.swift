//
//  KatalogMenuViewController.swift
//  RPGAapp
//
//  Created by Jakub on 09.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit



class catalogeMenu: UITableViewController {
    
    
    override func viewDidLoad() {
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return listOfItems.categories.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfItems.categories[section].2.count - 1
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catalogeMenuCell")
        cell?.textLabel?.text = listOfItems.categories[indexPath.section].2[indexPath.row].0
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return listOfItems.categories[section].0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
}
