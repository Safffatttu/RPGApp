//
//  CatalogeDetailViewController.swift
//  RPGAapp
//
//  Created by Jakub on 09.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit
import FontAwesome_swift

class catalogeDetailCell: UITableViewCell{
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet var packageButton: UIButton!
    
    @IBOutlet var editButton: UIButton!
    
    @IBOutlet var infoButton: UIButton!
    
    @IBOutlet var sendButton: UIButton!
    
    weak var cellDelegate: catalogeDetailCellDelegate?
    
    @IBAction func addToPackageButton(_ sender: UIButton) {
        cellDelegate?.addToPackageButton(sender.tag)
    }
    
    @IBAction func editItemButton(_ sender: UIButton) {
        cellDelegate?.editItemButton(sender.tag)
    }
    
    @IBAction func showInfoButton(_ sender: UIButton) {
        cellDelegate?.sendItemButton(sender.tag)
    }
    
    @IBAction func sendItemButton(_ sender: UIButton) {
        cellDelegate?.sendItemButton(sender.tag)
    }
    
    
}

protocol catalogeDetailCellDelegate: class{
   
    func addToPackageButton(_ tag: Int)
    
    func editItemButton(_ tag: Int)
    
    func showInfoButton(_ tag: Int)
    
    func sendItemButton(_ tag: Int)
    
}


class catalogeDetail: UIViewController, UITableViewDataSource, UITableViewDelegate, catalogeDetailCellDelegate{
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var currentSubCategory: String = ""
    let iconSize: CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: .reload, object: nil)
    }
    
    func reloadTableData(_ notification: Notification) {
        tableView.reloadData()
    }
    
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "catalogeDetailCell") as! catalogeDetailCell
        var cellAdress = Int()
        if (indexPath.section != 0){
            for i in 0...indexPath.section-1{
                cellAdress += (listOfItems.categories[i].1 - 1)
            }
        }
        cellAdress += indexPath.row
        
        cell.cellDelegate = self
        cell.tag = cellAdress
        
        
        cell.nameLabel.text = listOfItems.items[cellAdress].name
        
        var priceToShow = String()
        
        if settingValues["Show price"]! {
            if listOfItems.items[cellAdress].price != nil {
            priceToShow = String(describing: (listOfItems.items[cellAdress].price!)) //* listOfItems.exRate) + " " + listOfItems.currecny
            }
            else {
                priceToShow = "Brak ceny"
            }
        }

        cell.priceLabel.text = priceToShow
        
        
        cell.sendButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize)
        cell.sendButton.setTitle(String.fontAwesomeIcon(name: .send), for: .normal)

        cell.infoButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize)
        cell.infoButton.setTitle(String.fontAwesomeIcon(name: .info), for: .normal)
        
        cell.editButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize)
        cell.editButton.setTitle(String.fontAwesomeIcon(name: .edit), for: .normal)
        
        cell.packageButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize)
        cell.packageButton.setTitle(String.fontAwesomeIcon(name: .cube), for: .normal)
        
        return cell
    }
    
    func addToPackageButton(_ tag: Int){
        print(tag)
    }
    
    func editItemButton(_ tag: Int){
        print("edit \(tag)")
    }
    
    func showInfoButton(_ tag: Int){
        print(listOfItems.items[tag].name)
    }
    
    func sendItemButton(_ tag: Int){
        print("send \(tag)")
    }
    
    
}

