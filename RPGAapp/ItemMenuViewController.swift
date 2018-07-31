//
//  ItemsMenuViewController.swift
//  characterGen1
//
//  Created by Jakub on 06.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit

class ItemMenu: UITableViewController {

    let itemMenuItems = [("Katalog","showCatalogeView","showCatalogeDetailView"),
                         ("Losowanie Przedmiotu","showRandomItemView","showRandomItemDetailView"),
                         ("Handlarze","showHandlarzeView","showHandlarzeDetailView"),
                         ("Paczki","showPackageViewer","")]

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemMenuItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuItemCell")
        cell?.textLabel?.text = itemMenuItems[indexPath.row].0
        cell?.accessoryType = .disclosureIndicator
        return cell!
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCatalogeDetailView"{
            let controller = (segue.destination as! UINavigationController).topViewController as! catalogeDetail
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        if segue.identifier == "showRandomItemDetailView"{
            let controller = (segue.destination as! UINavigationController).topViewController as! RandomItemDetailView
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
        if segue.identifier == "showHandlarzeDetailView"{
            let controller = (segue.destination as! UINavigationController).topViewController as! handlarzeDetailView
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: itemMenuItems[indexPath.row].1, sender: self)
        if indexPath.row != 3{
            self.performSegue(withIdentifier: itemMenuItems[indexPath.row].2, sender: self)
        }
    }
}
