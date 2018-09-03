 //
//  NewItemForm.swift
//  RPGAapp
//
//  Created by Jakub on 18.05.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import UIKit
import Former
import CoreData

class NewItemForm: FormViewController{
	
	let categories: [Category] = Load.categories()
	var subCategories: [SubCategory] = Load.categories().first?.subCategories?.sortedArray(using: [.sortSubCategoryByName]) as! [SubCategory]
	
	var itemName = ""
	var itemDescription = ""
	lazy var itemCategory: Category = self.categories.first!
	lazy var itemSubCategory: SubCategory = self.subCategories.first!
	var price: Double = 0
	var quantity: Int16 = 0
	var rarity: Int16 = 1
	
	var item: Item? = nil{
		didSet{
			guard let item = item else { return }
			
			if let name = item.name {
				itemName = name
			}
			if let description = item.item_description{
				itemDescription = description
			}
			if let category = item.category{
				itemCategory = category
				subCategories = category.subCategories?.sortedArray(using: [.sortSubCategoryByName]) as! [SubCategory]
			}
			if let subCategory = item.subCategory{
				itemSubCategory = subCategory
			}
			
			price = item.price
			quantity = item.quantity
			rarity = item.rarity
		}
	}
	
	override func viewDidLoad() {
		let nameRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")){
				$0.titleLabel.text = NSLocalizedString("Name", comment: "")
			}.onTextChanged{[unowned self] in
				self.itemName = $0
			}.configure{
				$0.text = self.itemName
		}
		
		let subCategoryRow = InlinePickerRowFormer<FormInlinePickerCell,SubCategory>(){
			$0.titleLabel.text = NSLocalizedString("Subcategory", comment: "")
			}.configure{[unowned self] row in
				row.pickerItems = self.subCategories.map{
					InlinePickerItem(title: $0.name!, value: $0)
				}
				
				if let index = self.subCategories.index(of: self.itemSubCategory){
					row.selectedRow = index
				}
		}
		
		let categoryRow = InlinePickerRowFormer<FormInlinePickerCell,Category>(){
			$0.titleLabel.text = NSLocalizedString("Category", comment: "")
			}.configure{[unowned self] row in
				row.pickerItems = self.categories.map({
					InlinePickerItem(title: $0.name!, value: $0)
				})
				
				if let index = self.categories.index(of: self.itemCategory){
					row.selectedRow = index
				}
			}.onValueChanged{[unowned self] in
				self.subCategories = $0.value?.subCategories?.sortedArray(using: [.sortSubCategoryByName]) as! [SubCategory]

				subCategoryRow.configure{[unowned self] row in
					row.pickerItems = self.subCategories.map({
						InlinePickerItem(title: $0.name!, value: $0)
					})
				}
				
				subCategoryRow.update()
		}
		
		let descriptionRow = TextViewRowFormer<FormTextViewCell>()
			.configure{[unowned self] in
				if self.itemDescription != ""{
					$0.text = self.itemDescription
				}
				$0.placeholder = NSLocalizedString("Description", comment: "")
			}.onTextChanged{[unowned self] in
				self.itemDescription = $0
		}

		let priceRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")){
			$0.titleLabel.text = NSLocalizedString("Price", comment: "")
			}.configure{[unowned self] in
				$0.text = String(self.price)
			}.onTextChanged{[unowned self] in
				if let p = Double($0){
					self.price = p
				}
		}
		
		let rarityRow = SegmentedRowFormer<FormSegmentedCell>(){
			$0.titleLabel.text = NSLocalizedString("Rarity", comment: "")
			}.configure{[unowned self] in
				$0.segmentTitles = rarityName
				$0.selectedIndex = Int(self.rarity)
			}.onSegmentSelected{[unowned self] r,_ in
				self.rarity = Int16(r + 1)
		}
		
		let quantityRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")){
			$0.titleLabel.text = NSLocalizedString("Quantity", comment: "")
			}.configure{[unowned self] in
				$0.text = String(self.quantity)
			}.onTextChanged{[unowned self] in
				if let q = Int16($0){
					self.quantity = q
				}
		}
		
		let header = LabelViewFormer<FormLabelHeaderView>()
			.configure{[unowned self] in
				if self.item == nil{
					$0.text = NSLocalizedString("Create new item", comment: "")
				}else{
					$0.text = NSLocalizedString("Edit item", comment: "")
				}
		}
		
		let section = SectionFormer(rowFormers: [nameRow, categoryRow, subCategoryRow, descriptionRow, priceRow, quantityRow, rarityRow])
			.set(headerViewFormer: header)
		
		former.append(sectionFormer: section)
		
		let createItemRow = LabelRowFormer<CenteredLabelCell>(instantiateType: .Nib(nibName: "CenteredLabelCell"))
			.configure{[unowned self] in
				if self.item == nil{
					$0.text = NSLocalizedString("Create new item", comment: "")
				}else{
					$0.text = NSLocalizedString("Edit item", comment: "")
				}
			}.onSelected{[unowned self] _ in
				self.doneEditing()
		}
		
		let dissmissRow = LabelRowFormer<CenteredLabelCell>(instantiateType: .Nib(nibName: "CenteredLabelCell")){
				$0.centerTextLabel.textColor = .red
			}.configure{
			$0.text	= NSLocalizedString("Dismiss changes", comment: "")
			}.onSelected{[unowned self] _ in
				self.dismissView()
		}
	
		let secondSection = SectionFormer(rowFormers: [createItemRow,dissmissRow])
		former.append(sectionFormer: secondSection)
		
		tableView.isScrollEnabled = false 
		
		super.viewDidLoad()
	}
	
	func doneEditing(){
		guard itemName != "", price >= 0 else {
			shakeView(self.view)
			return
		}
		
		let newItem: Item!
		
		if let item = item {
			newItem = item
		}else{
			let contex = CoreDataStack.managedObjectContext
			newItem = NSEntityDescription.insertNewObject(forEntityName: String(describing: Item.self), into: contex) as! Item
		}
		
		newItem.name = itemName
		newItem.item_description = itemDescription
		newItem.price = price
		newItem.rarity = rarity
		newItem.category = itemCategory
		newItem.subCategory = itemSubCategory
		
		if item == nil{
			newItem.id = (newItem.name)! + String(describing: strHash(newItem.name! + (newItem.item_description)! + String(describing: newItem.price)))
		}
		
		CoreDataStack.saveContext()
		
		if item == nil{
			NotificationCenter.default.post(name: .createdNewItem, object: nil)
		}else{
			NotificationCenter.default.post(name: .editedItem, object: item)
		}
		
		dismissView()
	}
	
	func dismissView(){
		dismiss(animated: true, completion: nil)
	}
}

extension Notification.Name{
	static let createdNewItem = Notification.Name(rawValue: "createdNewItem")
	static let editedItem = Notification.Name(rawValue: "editedItem")
}

