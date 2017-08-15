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
        cellDelegate?.addToPackageButton(sender)
    }
    
    @IBAction func editItemButton(_ sender: UIButton) {
        cellDelegate?.editItemButton(sender)
    }
    
    @IBAction func showInfoButton(_ sender: UIButton) {
        cellDelegate?.sendItemButton(sender)
    }
    
    @IBAction func sendItemButton(_ sender: UIButton) {
        cellDelegate?.sendItemButton(sender)
    }
    
    
}

protocol catalogeDetailCellDelegate: class{
   
    func addToPackageButton(_ sender: UIButton)
    
    func editItemButton(_ sender: UIButton)
    
    func showInfoButton(_ sender: UIButton)
    
    func sendItemButton(_ sender: UIButton)
    
}


class catalogeDetail: UIViewController, UITableViewDataSource, UITableViewDelegate, catalogeDetailCellDelegate{
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let packageService = PackageService()
    
    var currentSubCategory: String = ""
    let iconSize: CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        packageService.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: .reload, object: nil)
    }
    
    func reloadTableData(_ notification: Notification) {
        tableView.reloadData()
    }
    
    func getCurrentCellIndexPath(_ sender: UIButton) -> IndexPath? {
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        if let indexPath: IndexPath = tableView.indexPathForRow(at: buttonPosition) {
            return indexPath
        }
        return nil
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
        
        if  listOfItems.items[cellAdress].price != nil  {
            if settingValues["Show price"]!{
                priceToShow = changeCurrency(price: listOfItems.items[cellAdress].price!, currency: listOfItems.currency)
            }
            else{
                priceToShow = String(listOfItems.items[cellAdress].price!) + "PLN"
            }
        }
        else {
            priceToShow = "Brak ceny"
            print(listOfItems.items[cellAdress])
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
    
    func addToPackageButton(_ sender: UIButton){
    if let indexPath = getCurrentCellIndexPath(sender){
        }
    }
    
    func editItemButton(_ sender: UIButton){
    }
    
    func showInfoButton(_ sender: UIButton){
    }
    
    func sendItemButton(_ sender: UIButton){
        let indexPath = getCurrentCellIndexPath(sender)
        print(indexPath?.row)
        var cellAdress = Int()
        if (indexPath?.section != 0){
            for i in 0...(indexPath?.section)!-1{
                cellAdress += (listOfItems.categories[i].1 - 1)
            }
        }
        packageService.sendPackage(itemToDend: listOfItems.items[cellAdress])
    }
}


extension catalogeDetail: PackageServiceDelegate{
    
    func connectedDevicesChanged(manager: PackageService, connectedDevices: [String]) {
        print("connections\(connectedDevices)")
    }
    func colorChanged(manager: PackageService, String: String) {
        OperationQueue.main.addOperation {
            print(String)
        }
    }
    
    
}



