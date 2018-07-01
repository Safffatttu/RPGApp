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
    
    var packages: [Package] = Load.packages(usingVisiblitiy: true)
	
	@IBOutlet var packagesTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPackages), name: .createdPackage, object: nil)
    }
	
    func reloadPackages(){
        packages = Load.packages()
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packages.count
    }
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PackageViewerCell") as! PackageViewerCell
		
		cell.package = packages[indexPath.row]
		
		return cell
	}
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
			let package = packages[indexPath.row]
            let packageId = package.id
            
            CoreDataStack.managedObjectContext.delete(package)
            CoreDataStack.saveContext()
			
            packages.remove(at: indexPath.row)
			
            tableView.deleteRows(at: [indexPath], with: .left)
			
            let action = NSMutableDictionary()
            let actionType = NSNumber(value: ActionType.packageDeleted.rawValue)
            
            action.setValue(actionType, forKey: "action")
            action.setValue(packageId, forKey: "packageId")
			
            PackageService.pack.send(action)
        }
    }
}
