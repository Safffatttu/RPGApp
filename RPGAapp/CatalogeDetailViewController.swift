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
import CoreData

class catalogeDetailCell: UITableViewCell{
    
    var item: Item? = nil
    
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
        cellDelegate?.showInfoButton(sender)
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


class catalogeDetail: UIViewController, UITableViewDataSource, UITableViewDelegate, catalogeDetailCellDelegate, UIPopoverPresentationControllerDelegate{
    
    
    @IBOutlet weak var tableView: UITableView!
    
    //let packageService = PackageService()
    
    var items: [Item] = []
    var subCategories: [SubCategory] = []
    
    let iconSize: CGFloat = 20
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //packageService.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: .reload, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goToSection), name: .goToSectionCataloge, object: nil)

        let context = CoreDataStack.managedObjectContext
        let itemFetch: NSFetchRequest<Item> = Item.fetchRequest()
        let subCategoryFetch: NSFetchRequest<SubCategory> = SubCategory.fetchRequest()
        
        itemFetch.sortDescriptors = [sortItemByCategory,sortItemBySubCategory,sortItemByName]
                
        do{
            items = try context.fetch(itemFetch)
        }
        catch let error as NSError{
           print(error)
        }
        
        subCategoryFetch.sortDescriptors = [sortSubCategoryByCategory,sortSubCategoryByName]
        
        do{
            subCategories = try context.fetch(subCategoryFetch)
        }
        catch{
            print("error fetching")
        }
        print(subCategories.map{$0.name})
    }
    
    func reloadTableData(_ notification: Notification) {
        tableView.reloadData()
    }
    
    func goToSection(_ notification: Notification) {
        let toGo = IndexPath(row: 0, section: goToLocation)
        tableView.scrollToRow(at: toGo, at: .top, animated: true)
    }

    func getCurrentCellIndexPath(_ sender: UIButton) -> IndexPath? {
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        if let indexPath: IndexPath = tableView.indexPathForRow(at: buttonPosition) {
            return indexPath
        }
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return subCategories.count
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (subCategories[section].items?.count)!
    }
    
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let category = subCategories[section].category?.name
        let subCategory = subCategories[section].name
        return category!.capitalized + " " + subCategory!.lowercased()
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catalogeDetailCell") as! catalogeDetailCell
        
        let cellItem = subCategories[indexPath.section].items?.sortedArray(using: [sortItemByName])[indexPath.row] as! Item
         
        cell.cellDelegate = self
        cell.item = cellItem
        
        cell.nameLabel.text = cellItem.name
        
        var priceToShow = String()
        
        if  cellItem.price != nil  {
            if UserDefaults.standard.bool(forKey: "Show price"){
                priceToShow = changeCurrency(price: cellItem.price, currency: listOfItems.currency)
            }
            else{
                priceToShow = String(cellItem.price) + "PLN"
            }
        }
        else {
            priceToShow = "Brak ceny"
            print(cellItem.price)
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
        let indexPath = getCurrentCellIndexPath(sender)
        
        let cellItem = subCategories[(indexPath?.section)!].items?.sortedArray(using: [sortItemByName])[(indexPath?.row)!] as! Item
        
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addToPackage")
        
        popController.modalPresentationStyle = .popover
        
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = sender
        
        (popController as! addToPackage).item = cellItem
        
        self.present(popController, animated: true, completion: nil)
        
    }
    
    func editItemButton(_ sender: UIButton){
    }
    
    func showInfoButton(_ sender: UIButton){
        let indexPath = getCurrentCellIndexPath(sender)

        let cellItem = subCategories[(indexPath?.section)!].items?.sortedArray(using: [sortItemByName])[(indexPath?.row)!] as! Item
        
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "showInfoPop")
        
        popController.modalPresentationStyle = .popover
        
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = sender
        
        (popController as! showItemInfoPopover).item = cellItem

        self.present(popController, animated: true, completion: nil)
    }
    
    func sendItemButton(_ sender: UIButton){
        let indexPath = getCurrentCellIndexPath(sender)
       
        let cellItem = subCategories[(indexPath?.section)!].items?.sortedArray(using: [sortItemByName])[(indexPath?.row)!] as! Item
        
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sendPop")
        
        popController.modalPresentationStyle = .popover
        
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = sender
        
        (popController as! sendPopover).item = cellItem

        self.present(popController, animated: true, completion: nil)
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



