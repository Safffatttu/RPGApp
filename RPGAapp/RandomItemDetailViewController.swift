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

class RandomItemDetailView: UIViewController, UITableViewDataSource, UITableViewDelegate, randomItemCellDelegate, UIPopoverPresentationControllerDelegate{
    
    let iconSize: CGFloat = 20
    
    @IBOutlet weak var tableView: UITableView!
    
    var diffCalculator: SingleSectionTableViewDiffCalculator<val>?
    
    struct val: Equatable {
        var name: String
        var count: Int64
        
        static func ==(lhs: RandomItemDetailView.val, rhs: RandomItemDetailView.val) -> Bool {
            return lhs.count == rhs.count && lhs.name == rhs.name
        }
    }
    
    var diffTable : [val] = []
    
    func setDiffTable(){
        diffTable = []
        for han in ItemDrawManager.randomlySelected{
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
    
    func reloadTableData() {
        setDiffTable()
        diffCalculator?.rows = diffTable
    }
    
    override func didReceiveMemoryWarning() {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "randomItemCell") as! randomItemCell
        
        if ItemDrawManager.randomlySelected.count > 0{
            let cellItem = ItemDrawManager.randomlySelected[indexPath.row]
            
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
                priceToShow = NSLocalizedString("Missing price", comment: "")
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
            cell.nameLabel?.text = NSLocalizedString("Have not draw items yet", comment: "")
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
            let handlerToRemove = ItemDrawManager.randomlySelected[indexPath.row]
            ItemDrawManager.randomlySelected.remove(at: indexPath.row)
			
			reloadTableData()
			
            contex.delete(handlerToRemove)
            CoreDataStack.saveContext()
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
        
        (popController as! addToPackage).itemToAdd = ItemDrawManager.randomlySelected[(indexPath?.row)!]
        
        self.present(popController, animated: true, completion: nil)
    }
    
    func reDrawItem(_ sender: UIButton){
		guard let indexPath = getCurrentCellIndexPath(sender, tableView: tableView) else { return }
		
		let handlerToReDraw = ItemDrawManager.randomlySelected[indexPath.row]
		
		ItemDrawManager.drawManager.reDrawItem(handler: handlerToReDraw)
		
		reloadTableData()
    }
    
    func showInfo(_ sender: UIButton){
        let indexPath = getCurrentCellIndexPath(sender, tableView: tableView)
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "showInfoPop")
        
        popController.modalPresentationStyle = .popover
        
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = sender
        (popController as! showItemInfoPopover).item = ItemDrawManager.randomlySelected[(indexPath?.row)!].item
        
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
        (popController as! sendPopover).itemHandler = ItemDrawManager.randomlySelected[(indexPath?.row)!]
        
        self.present(popController, animated: true, completion: nil)
    }
    
    @IBAction func reDrawAllItems(_ sender: UIButton){
        ItemDrawManager.drawManager.reDrawAllItems()
		reloadTableData()
    }
    
    @IBAction func addAllToPackage(_ sender: UIView) {
        if !sessionIsActive(){
            return
        }
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addToPackage")
        
        popController.modalPresentationStyle = .popover
        
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = sender
        
        (popController as! addToPackage).itemsToAdd = ItemDrawManager.randomlySelected
        
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
        (popController as! sendPopover).itemHandlers = ItemDrawManager.randomlySelected
        
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
