//
//  MasterViewController.swift
//  RPGAapp
//
//  Created by Jakub on 08.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import UIKit
import Foundation

class MasterViewController: UITableViewController {
    
    var menuItems = [("Items","showItemMenu"), ("TeamView","showTeamView"), ("Map", "showMap"), ("Losowanie","showRNG"), ("Settings" ,"showSettings")]
    
    override func viewDidLoad() {
        splitViewController?.preferredDisplayMode = .allVisible
    }
    
    func baseLoading(){
        let alert = UIAlertController(title: "Title", message: "Proszę czekać", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 50, y: 10, width: 37, height: 37))
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.setValue(loadingIndicator, forKey: "accessoryView")
        loadingIndicator.startAnimating()
        
        self.show(alert, sender: nil)
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
            if UserDefaults.standard.bool(forKey: "Auto hide menu"){
                self.splitViewController?.preferredDisplayMode = .primaryHidden
            }
        }
        else if segue.identifier == "showTeamView"{
            let controller = (segue.destination as!UINavigationController).topViewController as! TeamView
            
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
            if UserDefaults.standard.bool(forKey: "Auto hide menu"){
                self.splitViewController?.preferredDisplayMode = .primaryHidden
            }
        }
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
        cell.textLabel?.text = menuItems[indexPath.row].0
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(menuItems[indexPath.row].1)
        self.performSegue(withIdentifier: menuItems[indexPath.row].1, sender: self)
    }
}
