//
//  ItemDrawManager.swift
//  RPGAapp
//
//  Created by Jakub on 24.06.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import CoreData


class ItemDrawManager{
	
	static var randomlySelected: [ItemHandler] = []
	static let propabilities: [Int16] = [100,800,90,9,1]
	
	var lastDrawSetting: Any?
	
	static var drawManager: ItemDrawManager = ItemDrawManager()
	
	func drawItems(using: Any?, reDraw: Bool = false){
		var itemsToDraw: [Item] = []
		
		if !(UserDefaults.standard.bool(forKey: "Dodawaj do listy wylosowanych")) || reDraw {
			ItemDrawManager.randomlySelected = []
		}
		
		let numberOf: Int = 10
		
		if let drawSetting = using as? DrawSetting{
			
			let lists = listOfListToDrawFrom(drawSetting)
			
			for items in lists{
				drawItem(items: items.0, numberOf: items.1)
			}
			
			return
			
		}else if let subCategory = using as? SubCategory{
			
			itemsToDraw = subCategory.items?.sortedArray(using: [.sortItemByName]) as! [Item]
			
		}else if let category = using as? Category{
		
			itemsToDraw = category.items?.sortedArray(using: [.sortItemByName]) as! [Item]

		}else{
			
			itemsToDraw = Load.items()
			
		}
		
		drawItem(items: itemsToDraw, numberOf: numberOf)
		
		CoreDataStack.saveContext()
	}

	func drawItem(items: [Item], numberOf: Int){
		let weight: Int64
		var itemsToDraw = items
		
		itemsToDraw = items.map{
			$0.propability = Int64(ItemDrawManager.propabilities[Int($0.rarity) - 1])
			return $0
		}
		
		weight = Int64(itemsToDraw.map{$0.propability}.reduce(0,+))
		
		for _ in 1...numberOf{
			let newItem = weightedRandom(items: itemsToDraw, weightTotal: weight)
			var itemHandler = ItemDrawManager.randomlySelected.filter({$0.item == newItem}).first
			
			itemHandler?.count += 1
			
			if itemHandler == nil{
				let context = CoreDataStack.managedObjectContext
				itemHandler = (NSEntityDescription.insertNewObject(forEntityName: String(describing: ItemHandler.self), into: context) as! ItemHandler)
				itemHandler?.item = newItem
				ItemDrawManager.randomlySelected.append(itemHandler!)
			}
		}
	}
	
	func listOfListToDrawFrom(_ setting: DrawSetting) -> [([Item], Int)]{
		var listOfLists: [([Item], Int)] = []
		
		let subSettings: [DrawSubSetting] = setting.subSettings?.sortedArray(using: [.sortSubSettingByName]) as! [DrawSubSetting]
		
		for setting in subSettings{
			var itemsToDraw: [Item] = []
			
			if(setting.category != nil){
				itemsToDraw = setting.category?.items?.sortedArray(using: [.sortItemByName]) as! [Item]
			}
			else if(setting.subCategory != nil){
				itemsToDraw = setting.subCategory?.items?.sortedArray(using: [.sortItemByName]) as! [Item]
			}
			else if((setting.items?.count)! > 0){
				itemsToDraw = setting.items?.sortedArray(using: [.sortItemByName]) as! [Item]
			}
			else{
				itemsToDraw = Load.items()
			}
			
			itemsToDraw = itemsToDraw.filter({$0.rarity >= setting.minRarity && $0.rarity <= setting.maxRarity})
			
			if itemsToDraw.count == 0{
				continue
			}
			
			let itemCount = Int(setting.itemsToDraw)
			
			listOfLists.append((itemsToDraw, itemCount))
		}
		
		return listOfLists
	}
	
	func reDrawAllItems(){
		
		
		
	}
	
	func reDrawItem(handler: ItemHandler){
		
		guard let index = ItemDrawManager.randomlySelected.index(of: handler) else { return }
		
		let originalCount = Int(handler.count)
		
		let itemsToDraw: [Item]!
		
		if let drawSetting = lastDrawSetting as? DrawSetting{
			
			let listOfAllItems = listOfListToDrawFrom(drawSetting)

			itemsToDraw = listOfAllItems.flatMap{$0.0}
			
		} else if let subCategory = self.lastDrawSetting as? SubCategory{
			
			itemsToDraw = subCategory.items?.sortedArray(using: [.sortItemByName]) as! [Item]
			
		} else if let category = self.lastDrawSetting as? Category{
			
			itemsToDraw = category.items?.sortedArray(using: [.sortItemByName]) as! [Item]
			
		}else{
			
			itemsToDraw = Load.items()
		}

		drawItem(items: itemsToDraw, numberOf: originalCount)
		
		if ItemDrawManager.randomlySelected[index].count - Int64(originalCount) == 0{
			ItemDrawManager.randomlySelected.remove(at: index)
			
		}else{
			ItemDrawManager.randomlySelected[index].count = ItemDrawManager.randomlySelected[index].count - Int64(originalCount)
		}
		
		CoreDataStack.saveContext()
	}
}
