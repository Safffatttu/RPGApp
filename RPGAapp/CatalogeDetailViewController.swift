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
import Dwifft
import Former

let iconSize: CGFloat = 20

class catalogeDetail: UIViewController, UITableViewDataSource, UITableViewDelegate, catalogeDetailCellDelegate, UIPopoverPresentationControllerDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    var filter: [String : Double?] = [:]

	var sortModel: [(String,Bool,NSSortDescriptor)] = []
	
	var searchModel: [(String, Bool)] = []
	
	var lastSearchString: String = ""
	
    var expandedCell: IndexPath? = nil
	
    @IBOutlet weak var catalogTable: UITableView!
    
    var diffCalculator: TableViewDiffCalculator<SubCategory,Item>?
    
    var items: SectionedValues<SubCategory,Item> = SectionedValues(Load.itemsForCataloge()){
        didSet{
            self.diffCalculator?.sectionedValues = items
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        
        self.diffCalculator = TableViewDiffCalculator(tableView: self.tableView, initialSectionedValues: self.items)
		let localizedCreateItem = NSLocalizedString("Create item", comment: "")
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: localizedCreateItem, style: .plain, target: self, action: #selector(newItemForm))
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(goToSection(_:)), name: .goToSectionCataloge, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadFilter(_:)), name: .reloadCatalogeFilter, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(searchCataloge(_:)), name: .searchCataloge, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(searchModelChanged(_:)), name: .searchCatalogeModelChanged, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(sortModelChange(_:)), name: .sortModelChanged, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(reloadItems), name: .createdNewItem, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(reloadItems(_:)), name: .editedItem, object: nil)
		
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        deleteTempSubCategory()
        super.viewWillDisappear(animated)
    }
    
    func dismissKeyboard(){
        NotificationCenter.default.post(name: .dismissKeyboard, object: nil)
    }
	
	func newItemForm() {
		let form = NewItemForm()
		
		form.modalPresentationStyle = .formSheet
		form.preferredContentSize = CGSize(width: 540, height: 520)
		
		self.present(form, animated: true, completion: nil)
	}
	
	func reloadItems(_ not: Notification){
		if let item = not.object as? Item{
			
			guard let section = items.sectionsAndValues.index(where: {($0.0.items?.contains(item))!}) else { return }
			guard let row = items.sectionsAndValues[section].1.index(of: item) else { return }
			
			let path = IndexPath(row: row, section: section)
			
			tableView.reloadRows(at: [path], with: .fade)
		}else{
			items = SectionedValues(Load.itemsForCataloge())
		}
	}
	
	func sortModelChange(_ notification: Notification){
		if let newSortModel = notification.object as? [(String,Bool,NSSortDescriptor)]{
			sortModel = newSortModel
			
			items = RPGAapp.searchCataloge(searchWith: lastSearchString, using: searchModel, sortBy: sortModel)
		}
	}
	
	func searchModelChanged(_ notification: Notification){
		if let newSearchModel = notification.object as? [(String, Bool)]{
			searchModel = newSearchModel
			items = RPGAapp.searchCataloge(searchWith: lastSearchString, using: searchModel,sortBy: sortModel)
		}
	}
	
	func searchCataloge(_ notification: Notification){
		if let data = (notification.object as? (String,[(String, Bool)],[(String,Bool,NSSortDescriptor)])){
			let enteredString = data.0
			lastSearchString = enteredString
			
			let newSearchModel = data.1
			searchModel = newSearchModel
			
			let newSortModel = data.2
			sortModel = newSortModel
		
			items = RPGAapp.searchCataloge(searchWith: enteredString, using: searchModel,sortBy: sortModel)
		}
    }
    
    func reloadFilter(_ notification: Notification){
        if let newFilter = notification.object as? Dictionary<String, Double?>{
            DispatchQueue.global(qos: .default).sync {
                self.filter = newFilter
                var newSubCategoriesList: [(SubCategory,[Item])] = []
                for sub in Load.itemsForCataloge(){
                    let filteredList = self.filterItemList(sub.1)
					if filteredList.count != 0{
						newSubCategoriesList.append((sub.0),filteredList)
					}
                }
                
                DispatchQueue.main.async {
                    self.items = SectionedValues(newSubCategoriesList)
                }
            }
        }
    }
    
    func filterItemList( _ items: [Item]) -> [Item]{
        let minRarity = filter["minRarity"]
        let maxRarity = filter["maxRarity"]
        let minPrice = filter["minPrice"]
        let maxPrice = filter["maxPrice"]
        
        let itemsToRet = items.filter({
            $0.rarity >= Int16(minRarity!!) &&
                $0.rarity <= Int16(maxRarity!!) &&
                $0.price >= minPrice!! &&
                $0.price <= maxPrice!!
        })
        return itemsToRet
    }
	
    func goToSection(_ notification: Notification) {
        guard items.sectionsAndValues.count > 1  else {
            return
        }
        
        let subCategoryNumber = notification.object as! Int
        
        if tableView(self.tableView, numberOfRowsInSection: subCategoryNumber) != 0{
            let toGo = IndexPath(row: 0, section: subCategoryNumber)
            tableView.scrollToRow(at: toGo, at: .top, animated: true)
            
        }else if subCategoryNumber != 0
            && tableView(self.tableView, numberOfRowsInSection: subCategoryNumber - 1) != 0{
            let toGo = IndexPath(row: 0, section: subCategoryNumber - 1)
            tableView.scrollToRow(at: toGo, at: .top, animated: true)
            
        }else if subCategoryNumber != numberOfSections(in: self.tableView)
            && tableView(self.tableView, numberOfRowsInSection: subCategoryNumber + 1) != 0 {
            let toGo = IndexPath(row: 0, section: subCategoryNumber + 1)
            tableView.scrollToRow(at: toGo, at: .top, animated: true)
        }
    }
    
    //MARK: Table
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.diffCalculator?.numberOfSections() ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.diffCalculator?.numberOfObjects(inSection: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        
        if let subCategory = self.diffCalculator?.value(forSection: section).name{
            if let category = self.diffCalculator?.value(forSection: section).category?.name{
                title = category.capitalized + " " + subCategory.lowercased()
            }else{
                title = subCategory.capitalized
            }
        }
        return title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellItem = (self.diffCalculator?.value(atIndexPath: indexPath))!
		
		if expandedCell == indexPath{
            let cell = tableView.dequeueReusableCell(withIdentifier: "catalogDetailExpandedCell") as! CatalogeDetailExpandedCell
			
			cell.item = cellItem
			cell.cellDelegate = self
			
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "catalogeDetailCell") as! CatalogeDetailCell
            
            cell.cellDelegate = self
            cell.item = cellItem
			
			return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if expandedCell != nil && indexPath == expandedCell{
            return 150
        }else{
            return  44
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath != expandedCell else {
            return
        }
        
        if expandedCell != nil{
            let tmpIndex = expandedCell
            expandedCell = nil
            tableView.reloadRows(at: [tmpIndex!], with: .automatic)
        }
        expandedCell = indexPath
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        if tableView.cellForRow(at: indexPath) == tableView.visibleCells.first {
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }else if tableView.cellForRow(at: indexPath) == tableView.visibleCells.last {
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let removeAction = UITableViewRowAction(style: .destructive, title: "Remove", handler: {_,_ in
			
			guard let item = self.diffCalculator?.value(atIndexPath: indexPath) else { return }
			
			CoreDataStack.managedObjectContext.delete(item)
			CoreDataStack.saveContext()
			
			self.items = RPGAapp.searchCataloge(searchWith: self.lastSearchString, using: self.searchModel, sortBy: self.sortModel)
		})
		
		let sendAction = UITableViewRowAction(style: .normal, title: "Share item", handler: { _,_ in
			
			guard let item = self.diffCalculator?.value(atIndexPath: indexPath) else { return }
			
			let action = NSMutableDictionary()
			let actionType = NSNumber(value: ActionType.sessionReceived.rawValue)
			
			action.setValue(actionType, forKey: "action")
			
			let itemData = packItem(item)
			
			action.setValue(itemData, forKey: "itemData")
			
			PackageService.pack.send(action)
		})
		
		return [sendAction, removeAction]
	}
	
    //MARK: Cell Delegates
    
    func addToPackageButton(_ sender: UIButton){
        let indexPath = getCurrentCellIndexPath(sender, tableView: self.tableView)
        
        let cellItem = (self.diffCalculator?.value(atIndexPath: indexPath!))
        
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addToPackage")
        
        popController.modalPresentationStyle = .popover
        
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = sender
        
        (popController as! addToPackage).item = cellItem
        
        self.present(popController, animated: true, completion: nil)
    }
    
    func editItemButton(_ sender: UIButton){
		guard let indexPath = getCurrentCellIndexPath(sender, tableView: self.tableView) else { return }
		
		guard let item = self.diffCalculator?.value(atIndexPath: indexPath) else { return }
		
		let form = NewItemForm()
		
		form.item = item
		
		form.modalPresentationStyle = .formSheet
		
		self.present(form, animated: true, completion: nil)
    }
    
    func showInfoButton(_ sender: UIButton){
        let indexPath = getCurrentCellIndexPath(sender, tableView: self.tableView)
        
        let cellItem = (self.diffCalculator?.value(atIndexPath: indexPath!))
        
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "showInfoPop")
        
        popController.modalPresentationStyle = .popover
        
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = sender
        
        (popController as! showItemInfoPopover).item = cellItem
        
        self.present(popController, animated: true, completion: nil)
    }
    
    func sendItemButton(_ sender: UIButton){
        let indexPath = getCurrentCellIndexPath(sender, tableView: self.tableView)
        
        let cellItem = (self.diffCalculator?.value(atIndexPath: indexPath!))
        
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sendPop")
        
        popController.modalPresentationStyle = .popover
        
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = sender
        
        (popController as! sendPopover).item = cellItem

        self.present(popController, animated: true, completion: nil)
    }
}

protocol catalogeDetailCellDelegate: class{
    
    func addToPackageButton(_ sender: UIButton)
    
    func editItemButton(_ sender: UIButton)
    
    func showInfoButton(_ sender: UIButton)
    
    func sendItemButton(_ sender: UIButton)
    
}
