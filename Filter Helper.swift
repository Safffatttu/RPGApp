//
//  Filter helper.swift
//  RPGAapp
//
//  Created by Jakub on 29.08.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation


public struct FilterHelper{

	public static func filterItemList(_ items: [Item], using filter: [String: Double?]) -> [Item]{
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
	
	public static func itemList(using filter: [String: Double?]) -> [(String, [Item])]{
		let subCategories = Load.itemsForCataloge()
		
		var itemList: [(String, [Item])] = []
		
		for subCategory in subCategories{
			let subCategoryItems = filterItemList(subCategory.1, using: filter)

			guard subCategoryItems.count != 0 else { continue }
			
			itemList.append((subCategory.0, subCategoryItems))
		}
		
		return itemList
		
	}
	
	public static func subCategoryList(using filter: [String: Double?]) -> [(Category, [SubCategory])]{
		
		var subCategoryList: [(Category, [SubCategory])] = []
		
		let categories = Load.categories()
		
		for category in categories{
			guard let subCategories = category.subCategories?.sortedArray(using: [.sortSubSettingByName]) as? [SubCategory] else { continue }
			
			var fullSubCategories: [SubCategory] = []
			
			for subCategory in subCategories{
				guard let items = subCategory.items?.allObjects as? [Item] else { continue }
				
				let filteredList = filterItemList(items, using: filter)

				guard filteredList.count != 0  else { continue }
				
				fullSubCategories.append(subCategory)
			}
			
			
			guard fullSubCategories.count != 0 else { continue }
			subCategoryList.append((category, fullSubCategories))
		}
		
		return subCategoryList
	}
	
}
