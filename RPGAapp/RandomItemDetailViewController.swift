//
//  RandomItemDetailViewController.swift
//  RPGAapp
//
//  Created by Jakub on 11.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class randomItemDetailView: UIViewController, UITableViewDataSource, UITableViewDelegate, randomItemCellDelegate, UIPopoverPresentationControllerDelegate{
    
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
            //cell.nameLabel.text = listOfItems.items[randomlySelected[indexPath.row]].name
            cell.nameLabel.text = randomlySelected[indexPath.row].name
            var priceToShow = String()
            //if  listOfItems.items[randomlySelected[indexPath.row]].price != nil  {
            if  randomlySelected[indexPath.row].price != nil  {
                if UserDefaults.standard.bool(forKey: "Show price"){
                    //priceToShow = changeCurrency(price: listOfItems.items[randomlySelected[indexPath.row]].price!, currency: listOfItems.currency)
                    priceToShow = changeCurrency(price: randomlySelected[indexPath.row].price, currency: listOfItems.currency)
                }
                else{
                    //priceToShow = String(listOfItems.items[randomlySelected[indexPath.row]].price!) + "PLN"
                    priceToShow = String(randomlySelected[indexPath.row].price) + "PLN"
                }
            }
            else {
                priceToShow = "Brak ceny"
                print(randomlySelected[indexPath.row])
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
        
        cell.cellDelegate = self
        
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
        let indexPath = getCurrentCellIndexPath(sender)
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "showInfoPop")
        
        popController.preferredContentSize = CGSize(width: 300, height: 100)

        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.right
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = sender
        popController.popoverPresentationController?.sourceRect = CGRect(x:0, y: 13,width: 0,height: 0 )
        (popController as! showItemInfoPopover).item = randomlySelected[(indexPath?.row)!]
        self.present(popController, animated: true, completion: nil)
    }
    
    func sendItemButton(_ sender: UIButton){
        let indexPath = getCurrentCellIndexPath(sender)
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sendPop")
        var height =  Int()
        var y = Int()
        if (newTeam.count > 0){
            height = 45 * newTeam.count - 1
            y = 13
        }
        else{
            height = 45
            y = 24
        }

        popController.preferredContentSize = CGSize(width: 150, height: height)
        
        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.right
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = sender
        popController.popoverPresentationController?.sourceRect = CGRect(x:0, y: y,width: 0,height: 0 )
        (popController as! sendPopover).item = randomlySelected[(indexPath?.row)!]
        self.present(popController, animated: true, completion: nil)
    }
    
    func getCurrentCellIndexPath(_ sender: UIButton) -> IndexPath? {
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        if let indexPath: IndexPath = tableView.indexPathForRow(at: buttonPosition) {
            return indexPath
        }
        return nil
    }
    @IBAction func sendAll(_ sender: UIButton) {
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sendAllPop")
        var height =  Int()
        var y = Int()
        if (newTeam.count > 0){
            height = 45 * newTeam.count - 1
            y = 13
        }
        else{
            height = 45
            y = 24
        }
        
        popController.preferredContentSize = CGSize(width: 150, height: height)
        
        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = sender
        popController.popoverPresentationController?.sourceRect = CGRect(x:20, y: y,width: 0,height: 0 )

        self.present(popController, animated: true, completion: nil)
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
