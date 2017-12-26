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
    
    var currency: Currency? = nil
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.accessibilityIdentifier = "selectedTable"
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: .reloadRandomItemTable, object: nil)
        
        let context = CoreDataStack.managedObjectContext
        let currencyFetch: NSFetchRequest<Currency> = Currency.fetchRequest()
        
        do{
            currency = try context.fetch(currencyFetch).first
        }
        catch let error as NSError{
            print(error)
        }
        
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
        if let reloadData = notification.object as? (([Int],[Int]),IndexPath?){
            
            var cellsToReload: [IndexPath] = []
            
            for index in reloadData.0.0 {
                cellsToReload.append(IndexPath(row: index, section: 0))
            }
            
            var cellsToInsert: [IndexPath] = []
            
            for index in reloadData.0.1 {
                cellsToInsert.append(IndexPath(row: index, section: 0))
            }
            tableView.beginUpdates()

            tableView.reloadRows(at: cellsToReload, with: .automatic)
            tableView.insertRows(at: cellsToInsert, with: .automatic)

            if let index = reloadData.1 {
                tableView.deleteRows(at: [index], with: .automatic)
            }
            
            tableView.endUpdates()
            
        }else{
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "randomItemCell") as! randomItemCell
        
        if randomlySelected.count > 0{
            let num = randomlySelected[indexPath.row].count
            
            if num > 1 {
                cell.nameLabel.text = (randomlySelected[indexPath.row].item?.name)! + ": " + String(describing: randomlySelected[indexPath.row].count)
            }
            else{
                cell.nameLabel.text = (randomlySelected[indexPath.row].item?.name)!
            }
            
            var priceToShow = String()
            
            if  randomlySelected[indexPath.row].item?.price != nil  {
                if UserDefaults.standard.bool(forKey: "Show price"){
                    //priceToShow = changeCurrency(price: (randomlySelected[indexPath.row].item?.price)!, currency: listOfItems.currency)
                    priceToShow = String(describing: (randomlySelected[indexPath.row].item?.price)!) + "PLN"
                }
                else{
                    priceToShow = String(describing: (randomlySelected[indexPath.row].item?.price)!) + "PLN"
                }
            }
            else {
                priceToShow = "Brak ceny"
                print(randomlySelected[indexPath.row])
            }
            cell.priceLabel.text = priceToShow
            
            cell.sendButton.isHidden = false
            cell.infoButton.isHidden = false
            cell.redrawButton.isHidden = false
            cell.packageButton.isHidden = false

            cell.cellDelegate = self
            
            cell.sendButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize)
            cell.sendButton.setTitle(String.fontAwesomeIcon(name: .send), for: .normal)
            
            cell.infoButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize)
            cell.infoButton.setTitle(String.fontAwesomeIcon(name: .info), for: .normal)
            
            cell.redrawButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize)
            cell.redrawButton.setTitle(String.fontAwesomeIcon(name: .refresh), for: .normal)
            
            cell.packageButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize)
            cell.packageButton.setTitle(String.fontAwesomeIcon(name: .cube), for: .normal)
            
        }
        else{
            cell.nameLabel?.text = "Jeszcze nie wylosowano przedmiotów"
            cell.priceLabel?.text = ""
            
            cell.sendButton.isHidden = true
            cell.infoButton.isHidden = true
            cell.redrawButton.isHidden = true
            cell.packageButton.isHidden = true
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let contex = CoreDataStack.managedObjectContext
            let handlerToRemove = randomlySelected[indexPath.row]
            randomlySelected.remove(at: indexPath.row)
            contex.delete(handlerToRemove)
            CoreDataStack.saveContext()
            tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
    
    func addToPackage(_ sender: UIButton){
        if !sessionIsActive(){
            return
        }
        let indexPath = getCurrentCellIndexPath(sender, tableView: tableView)
        
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addToPackage")
        
        popController.modalPresentationStyle = .popover
        
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = sender
        
        (popController as! addToPackage).itemToAdd = randomlySelected[(indexPath?.row)!]
        
        self.present(popController, animated: true, completion: nil)
    }
    
    func reDrawItem(_ sender: UIButton){
        let indexPath = getCurrentCellIndexPath(sender, tableView: tableView)
        NotificationCenter.default.post(name: .reDrawItem, object: (randomlySelected[(indexPath?.row)!],indexPath))
    }
    
    func showInfo(_ sender: UIButton){
        let indexPath = getCurrentCellIndexPath(sender, tableView: tableView)
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "showInfoPop")
        
        popController.modalPresentationStyle = .popover
        
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = sender
        (popController as! showItemInfoPopover).item = randomlySelected[(indexPath?.row)!].item
        
        self.present(popController, animated: true, completion: nil)
    }
    
    func sendItem(_ sender: UIButton){
        if !sessionIsActive(){
            return
        }
        let indexPath = getCurrentCellIndexPath(sender, tableView: tableView)
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sendPop")

        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = sender
        (popController as! sendPopover).item = randomlySelected[(indexPath?.row)!].item
        
        self.present(popController, animated: true, completion: nil)
    }
    
    @IBAction func reDrawAllItems(_ sender: UIButton){
        NotificationCenter.default.post(name: .reDrawAllItems, object: nil)
    }
    
    @IBAction func addAllToPackage(_ sender: UIView) {
        if !sessionIsActive(){
            return
        }
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addToPackage")
        
        popController.modalPresentationStyle = .popover
        
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = sender
        
        (popController as! addToPackage).itemsToAdd = randomlySelected
        
        self.present(popController, animated: true, completion: nil)
    }
    
    
    @IBAction func sendAll(_ sender: UIButton) {
        if !sessionIsActive(){
            return
        }
    }
}

class randomItemCell: UITableViewCell{
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet var packageButton: UIButton!
    
    @IBOutlet var redrawButton: UIButton!
    
    @IBOutlet var infoButton: UIButton!
    
    @IBOutlet var sendButton: UIButton!
    
    weak var cellDelegate: randomItemCellDelegate?
    
    @IBAction func addToPackage(_ sender: UIButton) {
        cellDelegate?.addToPackage(sender)
    }
    
    @IBAction func redrawItem(_ sender: UIButton) {
        cellDelegate?.reDrawItem(sender)
    }
    
    @IBAction func showInfo(_ sender: UIButton) {
        cellDelegate?.showInfo(sender)
    }
    
    @IBAction func sendItem(_ sender: UIButton) {
        cellDelegate?.sendItem(sender)
    }
}

protocol randomItemCellDelegate: class{
    
    func addToPackage(_ sender: UIButton)
    
    func reDrawItem(_ sender: UIButton)
    
    func showInfo(_ sender: UIButton)
    
    func sendItem(_ sender: UIButton)
    
}
