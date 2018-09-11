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

class catalogeDetail: UIViewController, UIPopoverPresentationControllerDelegate{
    
    @IBOutlet weak var tableView: UITableView!
	
	var titleForSubCategory: [String: String] = createTitlesForSubCategory()
	
    var expandedCell: IndexPath? = nil
	
    @IBOutlet weak var catalogTable: UITableView!
    
    var diffCalculator: TableViewDiffCalculator<String,Item>?
    
    var items: SectionedValues<String,Item> = SectionedValues(CatalogeDataSource.source.items){
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
		NotificationCenter.default.addObserver(self, selector: #selector(reloadItems), name: .createdNewItem, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(reloadItems(_:)), name: .editedItem, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(reloadItems(_:)), name: .reloadCataloge, object: nil)
		
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
		items = SectionedValues(CatalogeDataSource.source.items)
	}
	
    func goToSection(_ notification: Notification) {
		guard let menuIndexPath = notification.object as? IndexPath else { return }
		let menuItem = CatalogeDataSource.source.menuItems[menuIndexPath.section].1[menuIndexPath.row]
		
		guard let index = items.sectionsAndValues.index(where: {$0.0 == menuItem}) else { return }
		let indexPath = IndexPath(row: 0, section: index)		
		
		tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
	
}

extension catalogeDetail: UITableViewDataSource, UITableViewDelegate{
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return self.diffCalculator?.numberOfSections() ?? 0
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.diffCalculator?.numberOfObjects(inSection: section) ?? 0
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard let subCategory = self.diffCalculator?.value(forSection: section) else { return "" }
		
		if let category = titleForSubCategory[subCategory] {
			return "\(category.capitalized) \(subCategory.lowercased())"
		}else{
			return subCategory.capitalized
		}
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
		let localizedRemove = NSLocalizedString("Remove", comment: "")
		let removeAction = UITableViewRowAction(style: .destructive, title: localizedRemove, handler: {_,_ in
			if indexPath == self.expandedCell{
				self.expandedCell = nil
			}
			
			guard let item = self.diffCalculator?.value(atIndexPath: indexPath) else { return }
			
			CoreDataStack.managedObjectContext.delete(item)
			CoreDataStack.saveContext()
		})
		
		let localizedShare = NSLocalizedString("Share item", comment: "")
		let sendAction = UITableViewRowAction(style: .normal, title: localizedShare, handler: { _,_ in
			
			guard let item = self.diffCalculator?.value(atIndexPath: indexPath) else { return }
			
			let itemData = packItem(item)
			
			let action = ItemsRequestResponse(itemsData: [itemData], requestId: "")
			PackageService.pack.send(action: action)
		})
		
		return [sendAction, removeAction]
	}
}

extension catalogeDetail: catalogeDetailCellDelegate{
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
		form.preferredContentSize = CGSize(width: 540, height: 520)
		
		self.present(form, animated: true, completion: nil)
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
	
	func sendItemToAllButton(_ sender: UIButton) {
		guard let index = getCurrentCellIndexPath(sender, tableView: tableView) else { return }
		guard let item = diffCalculator?.value(atIndexPath: index) else { return }
		
		let characters = Load.characters()
		
		for character in characters{
			addToEquipment(item: item, to: character)
			let action = ItemCharacterAdded(characterId: character.id!, itemId: item.id!)
			PackageService.pack.send(action: action)
		}
	}
}


protocol catalogeDetailCellDelegate: class{
	
    func addToPackageButton(_ sender: UIButton)
	
    func editItemButton(_ sender: UIButton)
	
    func sendItemButton(_ sender: UIButton)
	
	func sendItemToAllButton( _ sender: UIButton)
}
