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
    
    var subCtgs = listOfItems.items.map({$0.subCategory})
    var currentSubCategory: String = ""
    let iconSize: CGFloat = 20
    var orderedsubCtgs = NSArray()
    var cellAdresses = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //packageService.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: .reload, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goToSection), name: .goToSectionCataloge, object: nil)
        orderedsubCtgs = NSOrderedSet(array: subCtgs).array as NSArray
        //orderedsubCtgs.sorted(by: {String(describing: $0) > String(describing: $1)})
        var currentOfSet = Int()
        for i in 0...NSOrderedSet(array: subCtgs).count-1{
            currentOfSet += listOfItems.items.filter({$0.subCategory == orderedsubCtgs[i] as! String }).count
            cellAdresses.append(currentOfSet)
        }
    }
    
    func reloadTableData(_ notification: Notification) {
        tableView.reloadData()
    }
    
    func goToSection(_ notification: Notification) {
        let toGo = IndexPath(row: 0, section: goToLocation)
        tableView.scrollToRow(at: toGo, at: UITableViewScrollPosition.top, animated: true)
        
    }

    func getCurrentCellIndexPath(_ sender: UIButton) -> IndexPath? {
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        if let indexPath: IndexPath = tableView.indexPathForRow(at: buttonPosition) {
            return indexPath
        }
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return orderedsubCtgs.count
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfItems.items.filter({$0.subCategory == orderedsubCtgs[section] as! String }).count
    }
    
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let subCategory = (orderedsubCtgs[section] as! String)
        let category = listOfItems.items.first{$0.subCategory == subCategory}?.category
        return category!.capitalized + " " + subCategory.lowercased()
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catalogeDetailCell") as! catalogeDetailCell
        var cellAdress = Int()
        /*if (indexPath.section > 0){
            for i in 0...indexPath.section-1{
                if i > listOfItems.categories[catNum].2.count
                {
                    catNum += 1
                }
            cellAdress += (listOfItems.categories[catNum].2.count - 1)
            }
        }*/
        if indexPath.section > 0 {
            cellAdress = cellAdresses[indexPath.section - 1 ]
        }
        cellAdress += indexPath.row
        
        cell.cellDelegate = self
        cell.tag = cellAdress
        
        cell.nameLabel.text = listOfItems.items[cellAdress].name
        
        var priceToShow = String()
        
        if  listOfItems.items[cellAdress].price != nil  {
            if UserDefaults.standard.bool(forKey: "Show price"){
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
        let indexPath = getCurrentCellIndexPath(sender)
        var cellAdress = Int()
        /*if (indexPath?.section != 0){
            for i in 0...(indexPath?.section)!-1{
                cellAdress += (listOfItems.categories[i].1 - 1)
            }
        }else{
            cellAdress = (indexPath?.row)!
        }*/
        if (indexPath?.section)! > 0 {
            cellAdress = cellAdresses[(indexPath?.section)! - 1 ]
        }
        cellAdress += (indexPath?.row)!
        
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "showInfoPop")
        
        popController.preferredContentSize = CGSize(width: 300, height: 100)
        
        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.right
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = sender
        popController.popoverPresentationController?.sourceRect = CGRect(x:0, y: 13,width: 0,height: 0 )
        (popController as! showItemInfoPopover).item = listOfItems.items[cellAdress]
        self.present(popController, animated: true, completion: nil)

    
    
    }
    
    func sendItemButton(_ sender: UIButton){
        let indexPath = getCurrentCellIndexPath(sender)

        var cellAdress = Int()
        /*if (indexPath?.section != 0){
            for i in 0...(indexPath?.section)!-1{
                cellAdress += (listOfItems.categories[i].1 - 1)
            }
        }else{
            cellAdress = (indexPath?.row)!
        }*/
        if (indexPath?.section)! > 0 {
            cellAdress = cellAdresses[(indexPath?.section)! - 1 ]
        }
        cellAdress += (indexPath?.row)!
        //packageService.sendPackage(itemToDend: listOfItems.items[cellAdress])
        
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sendPop")
        /* Brzydki kod :( Chyba*/
        var height =  Int()
        var y = Int()
        if (team.count > 0){
            height = 45 * team.count - 1
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
        (popController as! sendPopover).item = listOfItems.items[cellAdress]
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



