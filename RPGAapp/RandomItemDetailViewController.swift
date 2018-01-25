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
import Dwifft

class randomItemDetailView: UIViewController, UITableViewDataSource, UITableViewDelegate, randomItemCellDelegate, UIPopoverPresentationControllerDelegate{
    
    let iconSize: CGFloat = 20
    
    @IBOutlet weak var tableView: UITableView!
    
    var diffCalculator: SingleSectionTableViewDiffCalculator<val>?
    
    struct val: Equatable {
        var name: String
        var count: Int64
        
        static func ==(lhs: randomItemDetailView.val, rhs: randomItemDetailView.val) -> Bool {
            return lhs.count == rhs.count && lhs.name == rhs.name
        }
    }
    
    var diffTable : [val] = []
    
    func setDiffTable(){
        diffTable = []
        for han in randomlySelected{
            let newVal = val(name: (han.item?.name)!, count: han.count)
            diffTable.append(newVal)
        }
    }
    
    override func viewDidLoad() {
        setDiffTable()
        self.diffCalculator = SingleSectionTableViewDiffCalculator(tableView: tableView, initialRows: diffTable, sectionIndex: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.accessibilityIdentifier = "selectedTable"
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: .reloadRandomItemTable, object: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.diffCalculator?.rows.count ?? 0
    }
    
    func reloadTableData(_ notification: Notification) {
        setDiffTable()
        diffCalculator?.rows = diffTable
    }
    
    override func didReceiveMemoryWarning() {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "randomItemCell") as! randomItemCell
        
        if randomlySelected.count > 0{
            let cellItem = randomlySelected[indexPath.row]
            
            if cellItem.count > 1 {
                cell.nameLabel.text = (cellItem.item?.name)! + ": " + String(describing: cellItem.count)
            }
            else{
                cell.nameLabel.text = (cellItem.item?.name)!
            }
            
            var priceToShow = String()
            
            if  cellItem.item?.price != nil  {
                if UserDefaults.standard.bool(forKey: "Show price"){
                    //priceToShow = changeCurrency(price: (cellItem.item?.price)!, currency: listOfItems.currency)
                    priceToShow = String(describing: (cellItem.item?.price)!) + "PLN"
                }
                else{
                    priceToShow = String(describing: (cellItem.item?.price)!) + "PLN"
                }
            }
            else {
                priceToShow = "Brak ceny"
                print(cellItem)
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
        (popController as! sendPopover).itemHandler = randomlySelected[(indexPath?.row)!]
        
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
        
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sendPop")
        
        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = sender
        (popController as! sendPopover).itemHandlers = randomlySelected
        
        self.present(popController, animated: true, completion: nil)
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
