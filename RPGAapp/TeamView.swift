//
//  TeamView.swift
//  RPGAapp
//
//  Created by Jakub on 10.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit


var team = [character]()


class TeamView: UICollectionViewController {
    
    override func viewDidLoad() {
        let addButton =  UIBarButtonItem.init(title: "Add", style: .plain, target: self, action: #selector(addCharacter(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        //self.splitViewController?.displayModeButtonItem = .
    }
    func addCharacter(_ sender: Any){
        let characterToAppend = character(name: "Postać",health: 10, race: "a", profesion: nil, abilites: [("WW",42),("US",22)], items: [123,222])
        team.append(characterToAppend)
        self.collectionView?.reloadData()
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return team.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TeamViewCell
        (cell.viewWithTag(1) as! UILabel).text = team[indexPath.row].name
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? TeamViewCell else { return }
        tableViewCell.setTableViewDataSourceDelegate(self, forRow: indexPath.row)
    }
}

extension TeamView: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell")
        if (cell != nil){
            return (team[tableView.tag].items?.count)!
        }
        else{
            return (team[tableView.tag].abilites?.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell")
        if (cell != nil) {
            let itemNum = team[tableView.tag].items?[indexPath.row]
            cell?.textLabel?.text = listOfItems.items[itemNum!].name
            return cell!
        }
        
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "abilityCell")
            let ablility = team[tableView.tag].abilites?[indexPath.row]
            let abilityToShow = (ablility?.0)! + ": " + String(describing: (ablility?.1)!)
            cell?.textLabel?.text = abilityToShow
            return cell!
        }
    }
    
    
}

class TeamViewCell: UICollectionViewCell {
    
    @IBOutlet var table: UITableView!
    
    @IBOutlet var ablilityTable: UITableView!
    
    func setTableViewDataSourceDelegate<D: UITableViewDataSource & UITableViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        //print(dataSourceDelegate.description)
        table.delegate = dataSourceDelegate
        table.dataSource = dataSourceDelegate
        table.tag = row
        ablilityTable.delegate = dataSourceDelegate
        ablilityTable.dataSource = dataSourceDelegate
        ablilityTable.tag = row
    }
}








