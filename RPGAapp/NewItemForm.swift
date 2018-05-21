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
	
	override func viewDidLoad() {
		let nameRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")){
				$0.titleLabel.text = "Name"
			}.onTextChanged{[unowned self] in
				self.itemName = $0
		}
		
		let subCatergoryRow = InlinePickerRowFormer<FormInlinePickerCell,SubCategory>(){
			$0.titleLabel.text = "Subcategory"
			}.configure{ row in
				row.pickerItems = subCategories.map{
					InlinePickerItem(title: $0.name!, value: $0)
				}
		}
		
		let catergoryRow = InlinePickerRowFormer<FormInlinePickerCell,Category>(){
			$0.titleLabel.text = "Category"
			}.configure{ row in
				row.pickerItems = categories.map({
					InlinePickerItem(title: $0.name!, value: $0)
				})
			}.onValueChanged{
				self.subCategories = $0.value?.subCategories?.sortedArray(using: [.sortSubCategoryByName]) as! [SubCategory]

				subCatergoryRow.configure{ row in
					row.pickerItems = self.subCategories.map({
						InlinePickerItem(title: $0.name!, value: $0)
					})
				}
				
				subCatergoryRow.update()
		}
		
		let descriptionRow = TextViewRowFormer<FormTextViewCell>()
			.configure{
				$0.text = "Description"
		}

		let priceRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")){
			$0.titleLabel.text = "Price"
			}.onTextChanged{[unowned self] in
				if let p = Double($0){
					self.price = p
				}
		}
		
		let rarityRow = SegmentedRowFormer<FormSegmentedCell>(){
			$0.titleLabel.text = "Rarity"
			}.configure{
				$0.segmentTitles = rarityName
				$0.selectedIndex = 1
			}.onSegmentSelected{ r,_ in
				self.rarity = Int16(r)
		}
		
		let quantityRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")){
			$0.titleLabel.text = "Quantiy"
			}.onTextChanged{[unowned self] in
				if let q = Int16($0){
					self.quantity = q
				}
		}
		
		let header = LabelViewFormer<FormLabelHeaderView>()
			.configure{
				$0.text = "Create new item"
			}
		
		let section = SectionFormer(rowFormers: [nameRow, catergoryRow, subCatergoryRow, descriptionRow, priceRow, rarityRow, quantityRow])
			.set(headerViewFormer: header)
		
		former.append(sectionFormer: section)
		
		let createItemRow = LabelRowFormer<CenteredLabelCell>(instantiateType: .Nib(nibName: "CenteredLabelCell"))
			.configure{
				$0.text = "Create new item"
			}.onSelected{_ in
				self.doneEditing()
		}
		
		let dissmissRow = LabelRowFormer<CenteredLabelCell>(instantiateType: .Nib(nibName: "CenteredLabelCell")){
				$0.centerTextLabel.textColor = .red
			}.configure{
				$0.text	= "Hide view"
			}.onSelected{_ in
				self.dismissView()
		}
	
		let secondSection = SectionFormer(rowFormers: [createItemRow,dissmissRow])
		former.append(sectionFormer: secondSection)
		
		super.viewDidLoad()
	}
	
	func doneEditing(){
		guard itemName != "" else { return }
		guard price >= 0 else { return }
		
		let contex = CoreDataStack.managedObjectContext
		let newItem = NSEntityDescription.insertNewObject(forEntityName: String(describing: Item.self), into: contex) as! Item
		
		newItem.name = itemName
		newItem.item_description = itemDescription
		newItem.price = price
		newItem.rarity = rarity
		newItem.category = itemCategory
		newItem.subCategory = itemSubCategory
		
		newItem.id = (newItem.name)! + String(describing: strHash(newItem.name! + (newItem.item_description)! + String(describing: newItem.price)))
		
		CoreDataStack.saveContext()
		
		NotificationCenter.default.post(name: .createdNewItem, object: nil)
		dismissView()
	}
	
	func dismissView(){
		dismiss(animated: true, completion: nil)
	}
}

extension Notification.Name{
	static let createdNewItem = Notification.Name(rawValue: "createdNewItem")
}

