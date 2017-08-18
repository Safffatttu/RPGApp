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
        let characterToAppend = character(name: "Postać",health: 10, race: "a", profesion: nil, abilites: nil,abilitesNames: nil, items: [])
        team.append(characterToAppend)
        team.append(characterToAppend)
        team[0].items?.append(40)
        team[1].items?.append(43)
        //self.splitViewController?.displayModeButtonItem = .
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
        return (team[tableView.tag].items?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print(tableView.tag)
        //print((tableView as UITableView).restorationIdentifier)
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell")
        
        if (cell != nil) {
            return cell!
        }
        
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "abilityCell")
            /*let itemNum = team[tableView.tag].items?[indexPath.row]
            cell?.textLabel?.text = listOfItems.items[itemNum!].name
            print(listOfItems.items[itemNum!].name)*/
            print(indexPath.row)
            cell?.textLabel?.text = String(indexPath.row)
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








