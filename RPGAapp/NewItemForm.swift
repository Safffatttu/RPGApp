//
//  NewItemForm.swift
//  RPGAapp
//
//  Created by Jakub on 18.05.2018.
//

import Foundation
import UIKit
import Former
import CoreData

class NewItemForm: FormViewController {
	
	let categories: [Category] = Load.categories()
	var subCategories: [SubCategory] = Load.categories().first?.subCategories?.sortedArray(using: [.sortSubCategoryByName]) as! [SubCategory]
	
	var itemName = ""
	var itemDescription = ""
	lazy var itemCategory: Category = self.categories.first!
	lazy var itemSubCategory: SubCategory = self.subCategories.first!
	var price: Double = 0
	var quantity: Int16 = 0
	var rarity: Int16 = 1
	
	var item: Item? = nil {
		didSet {
			guard let item = item else { return }
			
			if let name = item.name {
				itemName = name
			}
			if let description = item.item_description {
				itemDescription = description
			}
			if let category = item.category {
				itemCategory = category
				subCategories = category.subCategories?.sortedArray(using: [.sortSubCategoryByName]) as! [SubCategory]
			}
			if let subCategory = item.subCategory {
				itemSubCategory = subCategory
			}
			
			price = item.price
			quantity = item.quantity
			rarity = item.rarity
			
			if let atributes = item.itemAtribute?.sortedArray(using: [.sortItemAtributeByName]) as? [ItemAtribute] {
				self.atributes = atributes
			}
		}
	}
	
	var atributes: [ItemAtribute] = []
	
	var atributeMode: Bool = false
	
	override func viewDidLoad() {
		let itemSection = createItemSection()
		
		former.append(sectionFormer: itemSection)
		
		let createItemRow = LabelRowFormer<CenteredLabelCell>(instantiateType: .Nib(nibName: "CenteredLabelCell"))
			.configure {[unowned self] in
				if self.item == nil {
					$0.text = NSLocalizedString("Create new item", comment: "")
				}else {
					$0.text = NSLocalizedString("Edit item", comment: "")
				}
			}.onSelected {[unowned self] _ in
				self.doneEditing()
		}
		
		let switchModeRow = LabelRowFormer<CenteredLabelCell>(instantiateType: .Nib(nibName: "CenteredLabelCell"))
			.configure {
				if atributeMode {
					$0.text = NSLocalizedString("Show item properties", comment: "")
				}else {
					$0.text = NSLocalizedString("Show item atributes", comment: "")
				}
			}.onSelected {[unowned self] _ in
				self.switchDisplayMode()
		}
		
		let dissmissRow = LabelRowFormer<CenteredLabelCell>(instantiateType: .Nib(nibName: "CenteredLabelCell")) {
				$0.centerTextLabel.textColor = .red
			}.configure {
			$0.text	= NSLocalizedString("Dismiss changes", comment: "")
			}.onSelected {[unowned self] _ in
				self.dismissView()
		}
	
		let secondSection = SectionFormer(rowFormers: [createItemRow, switchModeRow, dissmissRow])
		former.append(sectionFormer: secondSection)
		
		super.viewDidLoad()
	}
	
	func switchDisplayMode() {
		self.atributeMode = !self.atributeMode
		
		if self.atributeMode {
			self.showItemAtributes()
		}else {
			self.showItemProperties()
		}
	}
	
	func showItemProperties() {
		let itemSection = self.createItemSection()
		let count = self.former.sectionFormers.count
		
		for _ in 0...count - 2 {
			self.former.remove(section: 0)
		}
		
		self.former.insert(sectionFormer: itemSection, toSection: 0)
		self.former.reload()
	}
	
	func showItemAtributes() {
		var atributesSections: [SectionFormer] = []
		
		for atribute in self.atributes {
			let newSection = createAtributeSection(using: atribute)
			atributesSections.append(newSection)
		}
		
		let addAtribute = addAtributeSection()
		atributesSections.append(addAtribute)
		
		self.former.remove(section: 0)
		self.former.insert(sectionFormers: atributesSections, toSection: 0)
		self.former.reload()
	}
	
	func createItemSection() -> SectionFormer {
		let nameRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) {
			$0.titleLabel.text = NSLocalizedString("Name", comment: "")
			}.onTextChanged {[unowned self] in
				self.itemName = $0
			}.configure {
				$0.text = self.itemName
		}
		
		let subCategoryRow = InlinePickerRowFormer<FormInlinePickerCell,SubCategory>() {
			$0.titleLabel.text = NSLocalizedString("Subcategory", comment: "")
			}.configure {[unowned self] row in
				row.pickerItems = self.subCategories.map {
					InlinePickerItem(title: $0.name!, value: $0)
				}
				
				if let index = self.subCategories.firstIndex(of: self.itemSubCategory) {
					row.selectedRow = index
				}
		}
		
		let categoryRow = InlinePickerRowFormer<FormInlinePickerCell,Category>() {
			$0.titleLabel.text = NSLocalizedString("Category", comment: "")
			}.configure {[unowned self] row in
				row.pickerItems = self.categories.map({
					InlinePickerItem(title: $0.name!, value: $0)
				})
				
				if let index = self.categories.firstIndex(of: self.itemCategory) {
					row.selectedRow = index
				}
			}.onValueChanged {[unowned self] in
				self.subCategories = $0.value?.subCategories?.sortedArray(using: [.sortSubCategoryByName]) as! [SubCategory]
				
				subCategoryRow.configure {[unowned self] row in
					row.pickerItems = self.subCategories.map({
						InlinePickerItem(title: $0.name!, value: $0)
					})
				}
				
				subCategoryRow.update()
		}
		
		let descriptionRow = TextViewRowFormer<FormTextViewCell>()
			.configure {[unowned self] in
				if self.itemDescription != ""{
					$0.text = self.itemDescription
				}
				$0.placeholder = NSLocalizedString("Description", comment: "")
			}.onTextChanged {[unowned self] in
				self.itemDescription = $0
		}
		
		let priceRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) {
			$0.titleLabel.text = NSLocalizedString("Price", comment: "")
			}.configure {[unowned self] in
				$0.text = String(self.price)
			}.onTextChanged {[unowned self] in
				if let p = Double($0) {
					self.price = p
				}
		}
		
		let rarityRow = SegmentedRowFormer<FormSegmentedCell>() {
			$0.titleLabel.text = NSLocalizedString("Rarity", comment: "")
			}.configure {[unowned self] in
				$0.segmentTitles = rarityName
				$0.selectedIndex = Int(self.rarity - 1)
			}.onSegmentSelected {[unowned self] r,_ in
				self.rarity = Int16(r + 1)
		}
		
		let quantityRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) {
			$0.titleLabel.text = NSLocalizedString("Quantity", comment: "")
			}.configure {[unowned self] in
				$0.text = String(self.quantity)
			}.onTextChanged {[unowned self] in
				if let q = Int16($0) {
					self.quantity = q
				}
		}
		
		let header = LabelViewFormer<FormLabelHeaderView>()
			.configure {[unowned self] in
				if self.item == nil {
					$0.text = NSLocalizedString("Create new item", comment: "")
				}else {
					$0.text = NSLocalizedString("Edit item", comment: "")
				}
		}
		
		let section = SectionFormer(rowFormers: [nameRow, categoryRow, subCategoryRow, descriptionRow, priceRow, quantityRow, rarityRow])
			.set(headerViewFormer: header)
		
		return section
	}
	
	func createAtributeSection(using atribute: ItemAtribute) -> SectionFormer {
		
		let nameRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) {
				$0.titleLabel.text = NSLocalizedString("Name", comment: "")
			}.configure {
				$0.text = atribute.name ?? ""
			}.onTextChanged {
				atribute.name = $0
		}
		
		let priceModRow = TextFieldRowFormer<NumberFieldCell>(instantiateType: .Nib(nibName: "NumberFieldCell")) {
				$0.titleLabel.text = NSLocalizedString("Price", comment: "")
				$0.allowFloatingPoint = true
			}.configure {
				$0.text = String(atribute.priceMod)
			}.onTextChanged {
				atribute.priceMod = Double($0) ?? 1
		}
		
		let rarityModRow = SegmentedRowFormer<FormSegmentedCell>() {
				$0.titleLabel.text = NSLocalizedString("Rarity", comment: "")
			}.configure {
				$0.segmentTitles = rarityName
				$0.selectedIndex = Int(atribute.rarityMod - 1)
			}.onSegmentSelected { r,_ in
				atribute.rarityMod = Int16(r + 1)
		}
		
		let removeAttributeRow = LabelRowFormer<CenteredLabelCell>(instantiateType: .Nib(nibName: "CenteredLabelCell")) {
			$0.centerTextLabel.textColor = .red
			}.configure {
				$0.text = NSLocalizedString("Remove attribute", comment: "")
			}.onSelected {[unowned self] _ in
				guard let sectionNumber = self.atributes.firstIndex(of: atribute) else { return }
				self.atributes.remove(at: sectionNumber)
				
				self.former.remove(section: sectionNumber)
				self.former.reload()
		}
		
		let header = LabelViewFormer<FormLabelHeaderView>()
			.configure {
				$0.text = NSLocalizedString("Atribute", comment: "")
		}
		
		let section = SectionFormer(rowFormers: [nameRow, priceModRow, rarityModRow, removeAttributeRow])
			.set(headerViewFormer: header)
		
		return section
	}
	
	func addAtributeSection() -> SectionFormer {
		let addAttributeRow = LabelRowFormer<CenteredLabelCell>(instantiateType: .Nib(nibName: "CenteredLabelCell"))
			.configure {
				$0.text = NSLocalizedString("Add new attribute", comment: "")
			}.onSelected {[unowned self] _ in
				let context = CoreDataStack.managedObjectContext
				let newAtribute = NSEntityDescription.insertNewObject(forEntityName: String(describing: ItemAtribute.self), into: context) as! ItemAtribute
				
				let sectionToInsert = self.atributes.count
				
				self.atributes.append(newAtribute)
				
				let newAtributeSection = self.createAtributeSection(using: newAtribute)
				
				self.former.insert(sectionFormer: newAtributeSection, toSection: sectionToInsert)
				self.former.reload()
		}
		
		let section = SectionFormer(rowFormer: addAttributeRow)
		
		return section
	}
	
	func doneEditing() {
		guard itemName != "", price >= 0 else {
			shakeView(self.view)
			return
		}
		
		let newItem: Item!
		
		if let item = item {
			newItem = item
		}else {
			let contex = CoreDataStack.managedObjectContext
			newItem = NSEntityDescription.insertNewObject(forEntityName: String(describing: Item.self), into: contex) as! Item
		}
		
		newItem.name = itemName
		newItem.item_description = itemDescription
		newItem.price = price
		newItem.rarity = rarity
		newItem.category = itemCategory
		newItem.subCategory = itemSubCategory
		
		if item == nil {
			newItem.id = (newItem.name)! + String(describing: strHash(newItem.name! + (newItem.item_description)! + String(describing: newItem.price)))
		}
		
		if let previousAttributes = newItem.itemAtribute {
			newItem.removeFromItemAtribute(previousAttributes)
		}
		
		let context = CoreDataStack.managedObjectContext
		
		for attribute in atributes {
			guard attribute.name != nil && attribute.name != "" else {
				context.delete(attribute)
				continue
			}
			
		 	attribute.id = (attribute.name)! + String(describing: strHash((attribute.name)! + String(describing: attribute.priceMod) + String(describing: (attribute.rarityMod))))
			newItem.addToItemAtribute(attribute)
		}
	
		let atributesToDelete = Load.itemAtributes().filter({$0.item == nil})
		atributesToDelete.forEach {context.delete($0)}
		
		CoreDataStack.saveContext()
		
		if item == nil {
			NotificationCenter.default.post(name: .createdNewItem, object: nil)
		}else {
			NotificationCenter.default.post(name: .editedItem, object: item)
		}
		
		dismissView()
	}
	
	func dismissView() {
		dismiss(animated: true, completion: nil)
	}
}

extension Notification.Name {
	static let createdNewItem = Notification.Name(rawValue: "createdNewItem")
	static let editedItem = Notification.Name(rawValue: "editedItem")
}
