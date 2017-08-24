//
//  RandomItemDetailViewController.swift
//  RPGAapp
//
//  Created by Jakub on 11.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit

class randomItemDetailView: UIViewController, UITableViewDataSource, UITableViewDelegate, randomItemCellDelegate{
    
    let iconSize: CGFloat = 20
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: .reloadRandomItemTable, object: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if randomlySelected.count > 0{
            return randomlySelected.count
        }
        else{
            return 1
        }
        
    }
    
    func reloadTableData(_ notification: Notification) {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "randomItemCell") as! randomItemCell
        if randomlySelected.count > 0{
            cell.nameLabel.text = listOfItems.items[randomlySelected[indexPath.row]].name
            var priceToShow = String()
            if  listOfItems.items[randomlySelected[indexPath.row]].price != nil  {
                if settingValues["Show price"]!{
                    priceToShow = changeCurrency(price: listOfItems.items[randomlySelected[indexPath.row]].price!, currency: listOfItems.currency)
                }
                else{
                    priceToShow = String(listOfItems.items[randomlySelected[indexPath.row]].price!) + "PLN"
                }
            }
            else {
                priceToShow = "Brak ceny"
                print(listOfItems.items[randomlySelected[indexPath.row]])
            }
            cell.priceLabel.text = priceToShow
            
        }
        else{
            cell.nameLabel?.text = "Jeszcze nie wylosowano przedmiotów"
            cell.priceLabel?.text = ""
            
            cell.sendButton.isHidden = true
            cell.infoButton.isHidden = true
            cell.editButton.isHidden = true
            cell.packageButton.isHidden = true
        }
        
        
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
    }
    
    func editItemButton(_ sender: UIButton){
    }
    
    func showInfoButton(_ sender: UIButton){
    }
    
    func sendItemButton(_ sender: UIButton){
    }
}

class randomItemCell: UITableViewCell{
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet var packageButton: UIButton!
    
    @IBOutlet var editButton: UIButton!
    
    @IBOutlet var infoButton: UIButton!
    
    @IBOutlet var sendButton: UIButton!
    
    weak var cellDelegate: randomItemCellDelegate?
    
    @IBAction func addToPackageButton(_ sender: UIButton) {
        cellDelegate?.addToPackageButton(sender)
    }
    
    @IBAction func editItemButton(_ sender: UIButton) {
        cellDelegate?.editItemButton(sender)
    }
    
    @IBAction func showInfoButton(_ sender: UIButton) {
        cellDelegate?.showInfoButton(sender)
    }
    
    @IBAction func sendItemButton(_ sender: UIButton) {
        cellDelegate?.sendItemButton(sender)
    }
}

protocol randomItemCellDelegate: class{
    
    func addToPackageButton(_ sender: UIButton)
    
    func editItemButton(_ sender: UIButton)
    
    func showInfoButton(_ sender: UIButton)
    
    func sendItemButton(_ sender: UIButton)
    
}
