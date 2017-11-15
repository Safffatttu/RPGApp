//
//  PackageViewer.swift
//  RPGAapp
//
//  Created by Jakub on 18.10.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PackageViewer: UITableViewController {
    
    var packages: [Package] = []
    
    @IBOutlet var packagesTable: UITableView!
    
    override func viewDidLoad() {
        let context = CoreDataStack.managedObjectContext
        let packageFetch: NSFetchRequest<Package> = Package.fetchRequest()
        packageFetch.sortDescriptors = [.sortPackageByName]

        do{
            packages = try context.fetch(packageFetch) as [Package]
        }
        catch{
            print(error)
        }
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView.dequeueReusableCell(withIdentifier: "PackageViewerCell") != nil){
            return packages.count
        }
        return (packages[tableView.tag].items?.count)!
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? PackageViewerCell else { return }
        print(indexPath.row)
        tableViewCell.setTableViewDataSourceDelegate(self, forRow: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PackageViewerCell"){
            cell.textLabel?.text = packages[indexPath.row].name
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PackageViewerItemCell")!
            let currentItemHandler = packages[tableView.tag].items?.sortedArray(using: [.sortItemHandlerByName])[indexPath.row] as! ItemHandler

            cell.textLabel?.text = (currentItemHandler.item?.name)! + ": " + String(describing: currentItemHandler.count)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView == packagesTable{
            return true
        }else{
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            CoreDataStack.managedObjectContext.delete(packages[indexPath.row])
            CoreDataStack.saveContext()
            packages.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
    
}

class PackageViewerCell: UITableViewCell{
    
    @IBOutlet var itemTable: UITableView!
    
    func setTableViewDataSourceDelegate<D: UITableViewDataSource & UITableViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        itemTable.dataSource = dataSourceDelegate
        itemTable.delegate = dataSourceDelegate
        itemTable.tag = row
    }
    
}
