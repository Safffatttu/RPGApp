//
//  addToPackage.swift
//  RPGAapp
//
//  Created by Jakub on 03.09.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import FontAwesome_swift

class addToPackage: UITableViewController, addToPackageDelegate {

    var packages: [Package] = Load.packages(usingVisiblitiy: true)
    
    var item: Item? = nil
    var itemToAdd: ItemHandler? = nil
    var itemsToAdd: [ItemHandler] = []
    
    let iconSize: CGFloat = 20
    
    override func viewDidLoad() {
        var height =  Int()
        var y = Int()
        if (packages.count > 0){
            height = 44 * (packages.count + 1)
            y = 13
        }
        else{
            height = 44
            y = 24
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPackages), name: .createdPackage, object: nil)
        
        self.preferredContentSize = CGSize(width: 200, height: height)
        self.popoverPresentationController?.sourceRect = CGRect(x:0, y: y,width: 0,height: 0)
        self.popoverPresentationController?.permittedArrowDirections = .right
        
        super.viewDidLoad()
    }
    
    func reloadPackages(){
        packages = Load.packages(usingVisiblitiy: true)
        tableView.reloadData()
        viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packages.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == packages.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "newPackageCell") as! newPackageCell
        
            cell.newPackageButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize)
            cell.newPackageButton.setTitle(String.fontAwesomeIcon(name: .plus), for: .normal)
            
            cell.cellDelegate = self
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "packageCell") as! packageCell
        cell.packageName.text = packages[indexPath.row].name
        
        cell.sendButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize)
        cell.sendButton.setTitle(String.fontAwesomeIcon(name: .send), for: .normal)
        
        cell.cellDelegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row < packages.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let packageId = packages[indexPath.row].id
            let session = Load.currentSession()
            session.removeFromPackages(packages[indexPath.row])
            CoreDataStack.managedObjectContext.delete(packages[indexPath.row])
            CoreDataStack.saveContext()
            packages.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            viewDidLoad()
            
            NotificationCenter.default.post(name: .createdPackage, object: nil)
            
            let action = NSMutableDictionary()
            let actionType = NSNumber(value: ActionType.packageDeleted.rawValue)
            
            action.setValue(actionType, forKey: "action")
            action.setValue(packageId, forKey: "packageId")
            
            PackageService.pack.send(action)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != packages.count{
            addToPackage(indexPath)
        }else{
            newPackage()
        }
    }
    
    func addToPackageButton(_ sender: UIButton) {
		guard let indexPath = getCurrentCellIndexPath(sender, tableView: self.tableView) else { return }
        addToPackage(indexPath)
    }
    
    func addToPackage(_ indexPath: IndexPath){
        let package = packages[indexPath.row]
		
		var itemsId: [String] = []
		var itemsCount: [Int64] = []
		
        if item != nil{
            add(item!, to: package, count: nil)
			itemsId = [(item?.id)!]
			itemsCount = [1]
        }else if (itemToAdd != nil){
            add((itemToAdd?.item!)!, to: package, count: itemToAdd?.count)
			itemsId = [(item?.id)!]
			itemsCount = [(itemToAdd?.count)!]
			
        }else{
            for item in itemsToAdd{
                add(item.item!, to: package, count: item.count)
				itemsId.append((item.item?.id)!)
				itemsCount.append(item.count)
            }
        }
        
        if UserDefaults.standard.bool(forKey: "Schowaj menu pakietów"){
            dismiss(animated: true, completion: nil)
        }
        CoreDataStack.saveContext()
		
		let action = ItemPackageAdded(package: package, itemsId: itemsId, itemsCount: itemsCount)
		
		PackageService.pack.send(action: action)
    }
    
    func newPackage(){
        let newPackage =  NSEntityDescription.insertNewObject(forEntityName: String(describing: Package.self), into: CoreDataStack.managedObjectContext) as! Package
        let number = packages.count
        
        newPackage.name = "Package nr." + String(number + 1)
        newPackage.id = newPackage.name! + String(describing: Date())
        let session = Load.currentSession()

		newPackage.visibility = Load.currentVisibility()
		
        session.addToPackages(newPackage)
		
        CoreDataStack.saveContext()
		
		reloadPackages()
		
        let action = NSMutableDictionary()
        let actionType = NSNumber(value: ActionType.packageCreated.rawValue)
        
        action.setValue(actionType, forKey: "action")
        action.setValue(newPackage.name, forKey: "packageName")
        action.setValue(newPackage.id, forKey: "packageId")
		
        PackageService.pack.send(action)
        
        NotificationCenter.default.post(name: .createdPackage, object: nil)
    }
}

class packageCell: UITableViewCell {
    
    weak var cellDelegate: addToPackageDelegate?
    
    @IBOutlet weak var packageName: UILabel!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBAction func addToPackage(_ sender: UIButton){
        cellDelegate?.addToPackageButton(sender)
    }
}

class newPackageCell: UITableViewCell {
    
    weak var cellDelegate: addToPackageDelegate?
    
    @IBOutlet weak var newPackageButton: UIButton!

    @IBAction func newPackage() {
        cellDelegate?.newPackage()
    }
}

protocol addToPackageDelegate: class {
    
    func addToPackageButton(_ sender: UIButton)
    
    func newPackage()
}

extension Notification.Name{
    static let createdPackage = Notification.Name("createdPackage")
}
