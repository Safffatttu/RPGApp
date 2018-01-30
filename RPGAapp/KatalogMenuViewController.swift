//
//  KatalogMenuViewController.swift
//  RPGAapp
//
//  Created by Jakub on 09.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class catalogeMenu: UITableViewController {
    
    var categories: [Category] = Load.categories()
    var subCategories: [SubCategory] = Load.subCategories()
    
    @IBOutlet weak var searchBar: UISearchBar!
	
	var searchMode: Bool = false
	
    var filter: [String: Double?] = [:]
	
	var searchModel: [(String, Bool)] = [("Search by name",true),("Search in description",true),("Search in category name ",false),("Search in sub category name",false),("Search by price",false),("Search by atribute name",false)]
	
	var sortModel: [(String,Bool,NSSortDescriptor)] = [("Sort by name",true, .sortItemByName),("Sort by rarity",false, .sortItemByRarity),("Sort by price",false, .sortItemByPrice)]
	
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(setFilters(_:)))
        NotificationCenter.default.addObserver(self, selector: #selector(reloadFilter(_:)), name: .reloadCatalogeFilter, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dismissKeyboard), name: .dismissKeyboard, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        super.viewWillAppear(animated)
    }
    
    func dismissKeyboard() {
        searchBar.endEditing(true)
    }
    
    
    func reloadFilter(_ notification: Notification){
        let newFilter = notification.object as? [String: Double?]
        if newFilter != nil{
            filter = newFilter!
            
        }
    }
    
    func setFilters(_ sender: UIBarButtonItem){
        let filterPopover = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "catalogeFilter") as! catalogeFilterPopover
        
        filterPopover.modalPresentationStyle = .popover

        filterPopover.popoverPresentationController?.sourceView = self.view
            //UIView(frame: CGRect(x: 500, y: 100, width: 300, height: 300))
        if filter.count != 0{
            filterPopover.filter = filter
        }
        
        self.present(filterPopover, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
		if searchMode {
			return 2
		}
		
		return categories.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if searchMode{
			if section == 0{
				return searchModel.count
			}else if section == 1{
				return sortModel.count
			}
		}
		
		return (categories[section].subCategories?.count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catalogeMenuCell")
		
		if searchMode{
			
			if indexPath.section == 0{
				cell?.textLabel?.text = searchModel[indexPath.row].0
				
				if searchModel[indexPath.row].1{
					cell?.accessoryType = .checkmark
				}else{
					cell?.accessoryType = .none
				}
				
			}else{
				cell?.textLabel?.text = sortModel[indexPath.row].0
			
				cell?.setSelected(sortModel[indexPath.row].1, animated: true)
				
				if sortModel[indexPath.row].1{
					cell?.accessoryType = .checkmark
				}else{
					cell?.accessoryType = .none
				}
			}
			
				cell?.selectionStyle = .none
		}else{
			let cellSubCategory = categories[indexPath.section].subCategories?.sortedArray(using: [.sortSubCategoryByCategory,.sortSubCategoryByName])[indexPath.row] as! SubCategory
				cell?.textLabel?.text = cellSubCategory.name?.capitalized
			cell?.accessoryType = .none
		}
		
		return cell!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if searchMode{
			return ""
		}
		
		return categories[section].name
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if searchMode{
			if indexPath.section == 0{
				searchModel[indexPath.row].1 = true
				
				NotificationCenter.default.post(name: .searchCatalogeModelChanged, object: searchModel)
				
			}else{
				sortModel[indexPath.row].1 = true
				
				NotificationCenter.default.post(name: .sortModelChanged, object: sortModel)
			}
			
			let cell = tableView.cellForRow(at: indexPath)
			cell?.accessoryType = .checkmark
			
		}else{
			let cellSubCategory = categories[indexPath.section].subCategories?.sortedArray(using: [.sortSubCategoryByCategory,.sortSubCategoryByName])[indexPath.row] as! SubCategory
			
			let goToLocation = subCategories.index(where: {$0.name == cellSubCategory.name})!
			
			NotificationCenter.default.post(name: .goToSectionCataloge, object: goToLocation)
		}
    }
	
	override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		if searchMode{
			
			if indexPath.section == 0{
				
				searchModel[indexPath.row].1 = false
				
				NotificationCenter.default.post(name: .searchCatalogeModelChanged, object: searchModel)
		
			}else{
				sortModel[indexPath.row].1 = false
				
				if sortModel.map({Int($0.1)}).reduce(0, {$0.0 + $0.1!}) == 0{
					
					sortModel[0].1 = true
					
					tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
				}
				
				NotificationCenter.default.post(name: .sortModelChanged, object: sortModel)
			}
			
			let cell = tableView.cellForRow(at: indexPath)
			cell?.accessoryType = .none
		}
	}
	
	override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		print(sortModel.filter({$0.1}).count <= 1)
		
		if indexPath == IndexPath(row: 0, section: 1) && sortModel.filter({$0.1}).count <= 1 {
			return nil
		}
		return indexPath
	}

	override func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
		print(sortModel.filter({$0.1}).count <= 1)
		if indexPath == IndexPath(row: 0, section: 1) && sortModel.filter({$0.1}).count <= 1 {
			return nil
		}
		return indexPath
	}
	
}

extension catalogeMenu: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		let searchFieldIsFull = searchText.replacingOccurrences(of: " ", with: "").characters.count > 0
		
		NotificationCenter.default.post(name: .searchCataloge, object: (searchText,searchModel,sortModel))
		
		if searchFieldIsFull {
			if searchMode == false{
				
				searchMode = true
				
				tableView.beginUpdates()
				
				let indexSet = IndexSet(integersIn: Range(uncheckedBounds: (2,categories.count)))
				tableView.deleteSections(indexSet, with: .automatic)
				
				let lastSectionIndex = IndexSet(integersIn: ClosedRange(uncheckedBounds: (0,1)))
				tableView.reloadSections(lastSectionIndex, with: .automatic)
				
				tableView.endUpdates()
			}
			
		}else{
			searchMode = false
			
			tableView.beginUpdates()
			
			let indexSet = IndexSet(integersIn: Range(uncheckedBounds: (2,categories.count)))
			tableView.insertSections(indexSet, with: .automatic)
			
			let lastSectionIndex = IndexSet(integersIn: ClosedRange(uncheckedBounds: (0,1)))
			tableView.reloadSections(lastSectionIndex, with: .automatic)
			
			tableView.endUpdates()
		}
    }
}

extension Notification.Name{
    static let goToSectionCataloge = Notification.Name("goToSectionCataloge")
    static let reloadCatalogeFilter = Notification.Name("reloadCatalogeFilter")
    static let searchCataloge = Notification.Name("searchCataloge")
    static let dismissKeyboard = Notification.Name("dismissKeyboard")
	static let searchCatalogeModelChanged = Notification.Name("searchCatalogeModelChanged")
	static let sortModelChanged = Notification.Name("sortModelChanged")
}
