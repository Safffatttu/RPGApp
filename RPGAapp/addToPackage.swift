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

    var packages: [Package] = []
    
    var item: Item? = nil
    
    var items: [ItemHandler]? = nil
    
    let iconSize: CGFloat = 20
    
    override func viewDidLoad() {
        loadPackages()
        
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
        
        self.preferredContentSize = CGSize(width: 200, height: height)
        self.popoverPresentationController?.sourceRect = CGRect(x:0, y: y,width: 0,height: 0)
        self.popoverPresentationController?.permittedArrowDirections = .right
        
        super.viewDidLoad()
    }
    
    func loadPackages(){
        let context = CoreDataStack.managedObjectContext
        
        let packageFetch: NSFetchRequest<Package> = Package.fetchRequest()
        packageFetch.sortDescriptors = [NSSortDescriptor(key: #keyPath(Package.name), ascending: true)]
        
        do{
            packages = try context.fetch(packageFetch)
        }
        catch{
            print("error")
        }
        
        tableView.reloadData()
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
            CoreDataStack.managedObjectContext.delete(packages[indexPath.row])
            packages.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            viewDidLoad()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != packages.count{
            addToPackage(indexPath)
        }
    }
    
    func addToPackageButton(_ sender: UIButton) {
        let indexPath = getCurrentCellIndexPath(sender)
        addToPackage(indexPath!)
    }
    
    func addToPackage(_ indexPath: IndexPath){
        print(indexPath.row)
        let package = packages[indexPath.row]
        if (item != nil){
            add(item!, to: package, count: nil)
        }else if(items != nil){
            for item in items!{
                add(item.item!, to: package, count: item.count)
            }
        }
        
        if UserDefaults.standard.bool(forKey: "Schowaj menu pakietów"){
            dismiss(animated: true, completion: nil)
        }
        CoreDataStack.saveContext()
    }
    
    func newPackage(_ sender: UIButton) {
        let newPackage =  NSEntityDescription.insertNewObject(forEntityName: String(describing: Package.self), into: CoreDataStack.managedObjectContext)
        let number = packages.count
        
        newPackage.setValue("Paczka nr." + String(number + 1), forKey: #keyPath(Package.name))
        
        CoreDataStack.saveContext()
        
        viewDidLoad()
    }
    
    func getCurrentCellIndexPath(_ sender: UIButton) -> IndexPath? {
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        if let indexPath: IndexPath = tableView.indexPathForRow(at: buttonPosition) {
            return indexPath
        }
        return nil
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

    @IBAction func newPackage(_ sender: UIButton) {
        cellDelegate?.newPackage(sender)
    }
}


protocol addToPackageDelegate: class {
    
    func addToPackageButton(_ sender: UIButton)
    
    func newPackage(_ sender: UIButton)
}
