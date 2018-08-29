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
	
	var titleForSubCategory: [String: String] = createTitlesForSubCategory()
	
    var filter: [String : Double?] = [:]

	var sortModel: [(String,Bool,NSSortDescriptor)] = []
	
	var searchModel: [(String, Bool)] = []
	
	var lastSearchString: String = ""
	
    var expandedCell: IndexPath? = nil
	
    @IBOutlet weak var catalogTable: UITableView!
    
    var diffCalculator: TableViewDiffCalculator<String,Item>?
    
    var items: SectionedValues<String,Item> = SectionedValues(Load.itemsForCataloge()){
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
		items = SectionedValues(Load.itemsForCataloge())
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
		guard let newFilter = notification.object as? [String: Double?] else { return }

		DispatchQueue.global(qos: .default).sync {
			self.filter = newFilter
			let itemList = FilterHelper.itemList(using: filter)
			
			DispatchQueue.main.async {
				self.items = SectionedValues(itemList)
			}
		}
    }
	
    func goToSection(_ notification: Notification) {
		guard let subCategory = notification.object as? SubCategory else { return }
		
		guard let index = items.sectionsAndValues.index(where: {$0.0 == subCategory.name}) else { return }
		let indexPath = IndexPath(row: 0, section: index)		
		
		tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    //MARK: Table
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.diffCalculator?.numberOfSections() ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.diffCalculator?.numberOfObjects(inSection: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard let subCategory = self.diffCalculator?.value(forSection: section) else { return "" }
		
		guard let category = titleForSubCategory[subCategory] else { return "" }
		
        return "\(category.capitalized) \(subCategory.lowercased())"
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
			expandedCell = nil
			tableView.reloadRows(at: [indexPath], with: .automatic)
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
