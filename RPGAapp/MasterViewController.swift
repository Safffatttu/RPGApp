//
//  MasterViewController.swift
//  RPGAapp
//
//  Created by Jakub on 08.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var listOfItems = loadItemList(data: loadStringTableFromDataAsset(Data: "ITEMS"))
    var characterDetailViewController: CharacterDetailViewController? = nil
    
    
    var menuItems = [("Items","showItemMenu"), ("TeamView","showTeamView"), ("Map", "showMap"), ("Settings" ,"showSettings")]
    

    override func viewDidLoad() {
        splitViewController?.preferredDisplayMode = .allVisible
        //splitViewController.preferredDisplayMode = .primaryOverlay
    }
    
    override func viewDidAppear(_ animated: Bool) {
        splitViewController?.preferredDisplayMode = .allVisible
    }
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showMap"{
            let controller = (segue.destination as!UINavigationController).topViewController as! MapViewController
            
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
            self.splitViewController?.preferredDisplayMode = .primaryHidden
        }
        else if segue.identifier == "showTeamView"{
            let controller = (segue.destination as!UINavigationController).topViewController as! TeamView
            
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
            self.splitViewController?.preferredDisplayMode = .primaryHidden
        }
            
            //let controller = (segue.destination as! UINavigationController).topViewController as! MapViewController
            //controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            //controller.navigationItem.leftItemsSupplementBackButton = true
        /*Dotyczy zmiany detail? chyba, albo navigation controllera
         
         
         if segue.identifier == "showItemMenu" {
         if let indexPath = tableView.indexPathForSelectedRow {
         let controller = (segue.destination as! UINavigationController).topViewController as! ItemMenu
         controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
         controller.navigationItem.leftItemsSupplementBackButton = true
         }
         }
         if segue.identifier == "showTeamView"{
         
         }*/
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Set appropriate labels for the cells.
        cell.textLabel?.text = menuItems[indexPath.row].0
        if indexPath.row == 0{
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(menuItems[indexPath.row].1)
        self.performSegue(withIdentifier: menuItems[indexPath.row].1, sender: self)
    }


}

