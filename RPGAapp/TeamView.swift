//
//  TeamView.swift
//  RPGAapp
//
//  Created by Jakub on 10.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit
import CoreData

var newTeam = [NSManagedObject]()

class TeamView: UICollectionViewController {
    
    override func viewDidLoad() {
        let addButton =  UIBarButtonItem.init(title: "Add", style: .plain, target: self, action: #selector(addCharacter(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTeam), name: .reloadTeam, object: nil)
        //self.splitViewController?.displayModeButtonItem = .
        reloadCoreData()
    }
    
    func addCharacter(_ sender: Any){
        
        let addCharControler = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addCharacter")
        addCharControler.modalPresentationStyle = .formSheet
        self.present(addCharControler, animated: true, completion: nil)
    }
    
    func reloadTeam(_ notification: Notification){
        reloadCoreData()
        collectionView?.reloadData()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newTeam.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TeamViewCell
        let person = newTeam[indexPath.row] as! Character
        (cell.viewWithTag(1) as! UILabel).text = person.name
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
            return (newTeam[tableView.tag] as! Character).equipment!.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell") {
            let equipment = (newTeam[tableView.tag] as! Character).equipment!.sortedArray(using: [sortItemByName]) as! [ItemHandler]
            cell.textLabel?.text = (equipment[indexPath.row].item?.name)!
            cell.detailTextLabel?.text = String(describing: (equipment[indexPath.row].itemAtributesHandler?.count)!)
            return cell
        }
        
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "abilityCell")
          //  let ablility = team[tableView.tag].abilites?[indexPath.row]
            //let abilityToShow = (ablility?.0)! + ": " + String(describing: (ablility?.1)!)
            //cell?.textLabel?.text = abilityToShow
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
extension Notification.Name{
    static let reloadTeam = Notification.Name("reloadTeam")
}









