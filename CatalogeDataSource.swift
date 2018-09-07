//
//  CatalogeDataSource.swift
//  RPGAapp
//
//  Created by Jakub on 07.09.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation

class CatalogeDataSource{
	
	static var source: CatalogeDataSource = CatalogeDataSource()
	
	init() {
//		NotificationCenter.default.addObserver(self, selector: #selector(reloadFilter(_:)), name: .reloadCatalogeFilter, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(searchCataloge(_:)), name: .searchCataloge, object: nil)
//		NotificationCenter.default.addObserver(self, selector: #selector(searchModelChanged(_:)), name: .searchCatalogeModelChanged, object: nil)
//		NotificationCenter.default.addObserver(self, selector: #selector(sortModelChange(_:)), name: .sortModelChanged, object: nil)
//		NotificationCenter.default.addObserver(self, selector: #selector(modelChanged), name: .catalogeModelChanged, object: nil)
	}
	
	private var filter: [String : Double?] = [:]
	private var sortModel: SortType = SortType.name
	private var searchModel: [(String, Bool)] = [(NSLocalizedString("Search by name", comment: "")			   ,true),
	                                             (NSLocalizedString("Search in description", comment: "")	   ,true),
	                                             (NSLocalizedString("Search in category name", comment: "")    ,false),
	                                             (NSLocalizedString("Search in sub category name", comment: ""),false),
	                                             (NSLocalizedString("Search by price", comment: "")			   ,false),
	                                             (NSLocalizedString("Search by atribute name", comment: "")    ,false)]
	
	private var searchString: String = ""{
		didSet{
			modelChanged()
		}
	
	}
	var items: [(String, [Item])] = Load.itemsForCataloge(){
		didSet{
			NotificationCenter.default.post(name: .reloadCataloge, object: nil)
		}
	}
	
	var menuItems: [String]{
		return items.map{$0.0}
	}
	
	private var searchedItems: [Item] = []
	private var filteredItems: [Item] = []
	
	private func modelChanged(){
		let allItems = Load.items()
		searchedItems = searchItems(allItems)
		filteredItems = filterItems(searchedItems)
		items = sortItems(filteredItems)
	}
	
	@objc private func searchCataloge(_ notification: Notification){
		guard let newString = notification.object as? String else { return }
		searchString = newString.replacingOccurrences(of: " ", with: "")
	}
	
	private func searchItems(_ list: [Item]) -> [Item]{
		guard searchString != "" else { return list }
		
		let searchedItems = list.filter({
				   ( searchModel[0].1 && ($0.name?.containsIgnoringCase(searchString))!)
				|| ( searchModel[1].1 && ($0.item_description?.containsIgnoringCase(searchString))!)
				|| ( searchModel[2].1 && ($0.category?.name?.containsIgnoringCase(searchString))!)
				|| ( searchModel[3].1 && ($0.subCategory?.name?.containsIgnoringCase(searchString))!)
				|| ( searchModel[4].1 && forTailingZero($0.price) == searchString)
				|| ( searchModel[5].1 && $0.itemAtribute?.filter(
						{(($0 as! ItemAtribute).name?.containsIgnoringCase(searchString))!}).count != 0)
		})
		return searchedItems
	}
	
	private func filterItems(_ list: [Item]) -> [Item]{
		guard filter.count != 0 else { return list }
		let filterdList = FilterHelper.filterItemList(list, using: filter)
		return filterdList
	}
	
	private func sortItems(_ list: [Item]) -> [(String, [Item])]{
		switch sortModel {
		case .categories:
			var subCategoryList: [(SubCategory, [Item])] = []
			
			for item in list{
				guard let itemSubCategory = item.subCategory else { continue }
				
				if let index = subCategoryList.index(where: {$0.0 == itemSubCategory}){
					subCategoryList[index].1.append(item)
				}else{
					subCategoryList.append((itemSubCategory, [item]))
				}
			}
			
			let namedSubCategoryList = subCategoryList.map{($0.0.name!, $0.1)}
			return namedSubCategoryList
			
		case .name:
			var alphabetDict: [String: [Item]] = [: ]
			
			for item in list{
				guard let itemNameLetter = item.name?.characters.first else { continue }
				let itemName = String(itemNameLetter)
				
				if alphabetDict[itemName] == nil{
					alphabetDict[itemName] = []
				}
				
				alphabetDict[itemName]?.append(item)
			}
			
			return Array(alphabetDict).sorted(by: {$0.key < $1.key})
			
		default:
			let localizedSearchResults = NSLocalizedString("Search results", comment: "")
			return [(localizedSearchResults, list)]
		}
	}
}

enum SortType{
	case categories
	case name
	case price
}

extension Notification.Name{
	static let reloadCataloge = Notification.Name(rawValue: "reloadCataloge")
	static let catalogeModelChanged = Notification.Name(rawValue: "catalogeModelChanged")
}
