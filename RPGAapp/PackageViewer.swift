//
//  PackageViewer.swift
//  RPGAapp
//
//  Created by Jakub on 18.10.2017.
//

import Foundation
import UIKit
import CoreData
import Dwifft

class PackageViewer: UITableViewController {
    
	var packages: [Package] = Load.packages(usingVisiblitiy: true) {
		didSet {
			diffCalculator?.rows = packages
		}
	}
	
	var diffCalculator: SingleSectionTableViewDiffCalculator<Package>?
	
	@IBOutlet var packagesTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		diffCalculator = SingleSectionTableViewDiffCalculator(tableView: self.tableView, initialRows: packages, sectionIndex: 0)
		
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPackages), name: .createdPackage, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(reloadPackages), name: .reloadTeam, object: nil)
    }
	
    @objc func reloadPackages() {
        packages = Load.packages()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let count = diffCalculator?.rows.count {
			return count
		}else {
			return 0
		}
    }
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PackageViewerCell") as! PackageViewerCell
		
		cell.package = diffCalculator?.rows[indexPath.row]
		cell.selectionStyle = .none
		
		return cell
	}
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
			guard let package = diffCalculator?.rows[indexPath.row] else { return }
            let packageId = package.id
            
            CoreDataStack.managedObjectContext.delete(package)
            CoreDataStack.saveContext()
			
            packages.remove(at: indexPath.row)
			
			let action = PackageDeleted(packageId: packageId!)
			PackageService.pack.send(action: action)
        }
    }
}
