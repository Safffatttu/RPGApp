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
	
	var list: [(Category, [SubCategory])] = Load.subCategoriesFormCatalogeMenu(){
		didSet{
			tableView.reloadData()
		}
	}
	
    @IBOutlet weak var searchBar: UISearchBar!
	
	var searchMode: Bool = false
	
    var filter: [String: Double?] = [:]
	
	var searchModel: [(String, Bool)] = [(NSLocalizedString("Search by name", comment: "")			   ,true),
	                                     (NSLocalizedString("Search in description", comment: "")	   ,true),
	                                     (NSLocalizedString("Search in category name", comment: "")    ,false),
	                                     (NSLocalizedString("Search in sub category name", comment: ""),false),
	                                     (NSLocalizedString("Search by price", comment: "")			   ,false),
	                                     (NSLocalizedString("Search by atribute name", comment: "")    ,false)]
	
	var sortModel: [(String,Bool,NSSortDescriptor)] = [
		(NSLocalizedString("Sort by name", comment: "")   ,true , .sortItemByName),
		(NSLocalizedString("Sort by rarity", comment: "") ,false, .sortItemByRarity),
		(NSLocalizedString("Sort by price", comment: "")  ,false, .sortItemByPrice)
	]
	
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
		guard let newFilter = notification.object as? [String: Double?] else { return }

		filter = newFilter
		list = FilterHelper.subCategoryList(using: filter)
    }
    
    func setFilters(_ sender: UIBarButtonItem){
        let filterPopover = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "catalogeFilter") as! CatalogeFilterPopover
        
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
		
		return list.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if searchMode{
			if section == 0{
				return searchModel.count
			}else if section == 1{
				return sortModel.count
			}
		}
		
		return list[section].1.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catalogeMenuCell")
		
		if searchMode{
			
			if indexPath.section == 0{
				cell?.textLabel?.text = searchModel[indexPath.row].0
				
				cell?.setSelected(searchModel[indexPath.row].1, animated: true)
				
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
			let cellSubCategory = list[indexPath.section].1[indexPath.row]

			cell?.textLabel?.text = cellSubCategory.name?.capitalized
			cell?.accessoryType = .none
		}
		
		return cell!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if searchMode{
			return ""
		}
		
		return list[section].0.name
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if searchMode{
			if indexPath.section == 0{
				searchModel[indexPath.row].1 = true
				
				if searchModel.filter({$0.1}).count == 0 && indexPath.row != 0{
					searchModel[0].1 = true
					tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
				}
				
				NotificationCenter.default.post(name: .searchCatalogeModelChanged, object: searchModel)
				
			}else{
				let index = sortModel.index(where: {$0.1})!
				sortModel[index].1 = false
				
				tableView.reloadRows(at: [IndexPath(row: index, section: 1)], with: .automatic)
				
				sortModel[indexPath.row].1 = true
				
				NotificationCenter.default.post(name: .sortModelChanged, object: sortModel)
			}
			
			let cell = tableView.cellForRow(at: indexPath)
			cell?.accessoryType = .checkmark
			
		}else{
			let cellSubCategory = list[indexPath.section].1[indexPath.row]
			
			NotificationCenter.default.post(name: .goToSectionCataloge, object: cellSubCategory)
		}
    }
	
	override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		if searchMode{
			
			if indexPath.section == 0{
				searchModel[indexPath.row].1 = false
				
				NotificationCenter.default.post(name: .searchCatalogeModelChanged, object: searchModel)
		
			}else{
				sortModel[indexPath.row].1 = false
				
				if sortModel.filter({!($0.1)}).count == 0{
					
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
		if searchMode && indexPath.section == 1 && sortModel[indexPath.row].1  {
			return nil
		}
		return indexPath
	}

	override func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
		if searchMode && indexPath.section == 1 && sortModel[indexPath.row].1{
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
				
				let indexSet = IndexSet(integersIn: Range(uncheckedBounds: (2, list.count)))
				tableView.deleteSections(indexSet, with: .automatic)
				
				let lastSectionIndex = IndexSet(integersIn: ClosedRange(uncheckedBounds: (0,1)))
				tableView.reloadSections(lastSectionIndex, with: .automatic)
				
				tableView.endUpdates()
			}
			
		}else{
			searchMode = false
			
			tableView.beginUpdates()
			
			let indexSet = IndexSet(integersIn: Range(uncheckedBounds: (2, list.count)))
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
