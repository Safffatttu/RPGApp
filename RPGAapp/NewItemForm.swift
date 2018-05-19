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
	
	var itemName = "Name"
	var item_description = ""
	var itemCategory: Category!
	var itemSubCategory: SubCategory!
	var price: Double = 0
	var quantity: Int16 = 0
	var rarity: Int16 = 1
	
	override func viewWillAppear(_ animated: Bool) {

		
		let nameRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")){
				$0.titleLabel.text = "Name"
			}.onTextChanged{[unowned self] in
				self.itemName = $0
		}
		
		let subCatergoryRow = InlinePickerRowFormer<FormInlinePickerCell,SubCategory>(){
			$0.titleLabel.text = "Subcategory"
			}.configure{ row in
				row.pickerItems = subCategories.map({
					InlinePickerItem(title: $0.name!, value: $0)
				})
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
				print(self.subCategories.map({$0.name}))
		}
		
		let rarityRow = SegmentedRowFormer<FormSegmentedCell>(){
			$0.titleLabel.text = "Rarity"
			}.configure{
				$0.segmentTitles = rarityName
				$0.selectedIndex = 1
			}.onSegmentSelected{
				print($0)
		}
		
		
		let section = SectionFormer(rowFormers: [nameRow,catergoryRow,subCatergoryRow,rarityRow])

		former.append(sectionFormer: section)
	}
	
	func doneEditing(){
		
	}
	
	
}
