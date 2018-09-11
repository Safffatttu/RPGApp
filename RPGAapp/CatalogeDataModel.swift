//
//  CatlogeModelItem.swift
//  RPGAapp
//
//  Created by Jakub on 09.09.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation

enum SortType{
	case categories
	case name
	case price
	case rarity
}

enum FilterType{
	case rarity
	case price
}

enum FilterMode{
	case min
	case max
}

protocol CatalogeModelSection: class{
	var name: String { get }
	subscript(index: Int) -> CatalogeModelItem { get }
	
	func select(index: Int) -> Void
	var count: Int { get }
}

protocol CatalogeModelItem: class{
	var name: String { get }
	var cellName: String { get }
	var selected: Bool { get }
}

final class CatalogeSearchItem: CatalogeModelItem{
	fileprivate(set) var name: String
	fileprivate(set) var cellName: String = "catalogeMenuCell"
	fileprivate(set) var selected: Bool
	
	init(name: String, selected: Bool){
		self.name = name
		self.selected = selected
	}
}

final class CatelogeSortItem: CatalogeModelItem{
	fileprivate(set) var name: String
	fileprivate(set) var cellName: String = "catalogeMenuCell"
	fileprivate(set) var selected: Bool
	
	fileprivate(set) var type: SortType
	
	init(name: String, selected: Bool, type: SortType){
		self.name = name
		self.selected = selected
		self.type = type
	}
}

final class CatalogeFilterItem: CatalogeModelItem{
	var name: String{
		switch (filterType, filterMode){
		case (.rarity, .min):
			return NSLocalizedString("Min rarity", comment: "")
		case (.rarity, .max):
			return NSLocalizedString("Max rarity", comment: "")
		case (.price, .min):
			return NSLocalizedString("Min price", comment: "")
		case (.price, .max):
			return NSLocalizedString("Max price", comment: "")
		}
	}
	
	fileprivate(set) var selected: Bool = false
	fileprivate(set) var filterType: FilterType
	fileprivate(set) var filterMode: FilterMode
	fileprivate(set) var range: (Double, Double)
	var value: Double{
		didSet{
			NotificationCenter.default.post(name: .catalogeModelChanged, object: nil)
		}
	}
	
	var cellName: String{
		switch filterType {
		case .price:
			return "catalogeFilterSlider"
		case .rarity:
			return "catalogeFilterStepper"
		}
		
	}
	
	init(type: FilterType, mode: FilterMode, range: (Double, Double)){
		self.filterType = type
		self.filterMode = mode
		self.range = range
		
		if filterMode == .min{
			self.value = range.0
		}else{
			self.value = range.1
		}
	}
	
}

final class CatalogeSortSection: CatalogeModelSection{
	var name: String = "Sort"
	
	private var store: [CatelogeSortItem]
	
	init(list: [CatelogeSortItem]){
		store = list
	}
	
	subscript(index: Int) -> CatalogeModelItem {
		return store[index]
	}
	
	var count: Int {
		return store.count
	}
	
	func select(index: Int){
		for (number, item) in self.store.enumerated(){
			item.selected = (number == index)
		}
		NotificationCenter.default.post(name: .catalogeModelChanged, object: nil)
	}
	
	var sortBy: SortType{
		if let selectedType = store.first(where: {$0.selected})?.type{
			return selectedType
		}else{
			return SortType.categories
		}
	}
}

final class CatalogeSearchSection: CatalogeModelSection{
	var name: String = "Search"
	private var store: [CatalogeSearchItem]
	
	init(list: [CatalogeSearchItem]){
		self.store = list
	}
	
	subscript(index: Int) -> CatalogeModelItem{
		get{
			return store[index]
		}
	}
	
	var count: Int {
		return store.count
	}
	
	func select(index: Int){
		store[index].selected = !(store[index].selected)
		NotificationCenter.default.post(name: .catalogeModelChanged, object: nil)
	}
}

final class CatalogeFilterSection: CatalogeModelSection{
	var name: String = "Filter"
	private var store: [CatalogeModelItem]

	init(list: [CatalogeModelItem]){
		self.store = list
		NotificationCenter.default.addObserver(self, selector: #selector(reloadPriceRange), name: .createdNewItem, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(reloadPriceRange), name: .editedItem, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(reloadPriceRange), name: .receivedItemData, object: nil)
	}
	
	subscript(index: Int) -> CatalogeModelItem{
		get{
			return store[index]
		}
	}
	
	var count: Int{
		return store.count
	}
	
	func select(index: Int){
		return
	}
	
	@objc private func reloadPriceRange(){
		let range = Load.priceRange
		let priceFilters = store.filter({($0 as? CatalogeFilterItem)?.filterType == FilterType.price})
		for case let filter as CatalogeFilterItem in priceFilters{
			filter.range = range
		}
		NotificationCenter.default.post(name: .reloadFilterRange, object: nil)
	}
	
	var filterItems: [CatalogeFilterItem]{
		return store.flatMap{
			guard let filterItem = $0 as? CatalogeFilterItem else { return nil }
			
			let isChanged: Bool
			
			switch filterItem.filterMode {
			case .min:
				isChanged = filterItem.range.0 != filterItem.value
			case .max:
				isChanged = filterItem.range.1 != filterItem.value
			}
			
			guard isChanged else { return nil }
			
			return filterItem
		}
	}
}

final class CatalogeModel{
	private var sections: [CatalogeModelSection]{
		return [sortModel, searchModel, filterModel]
	}
	
	private(set) var sortModel: CatalogeSortSection
	private(set) var searchModel: CatalogeSearchSection
	private(set) var filterModel: CatalogeFilterSection
	
	init(sortSection: CatalogeSortSection, searchSection: CatalogeSearchSection, filterSection: CatalogeFilterSection) {
		self.sortModel = sortSection
		self.searchModel = searchSection
		self.filterModel = filterSection
	}
	
	subscript(index: Int) -> CatalogeModelSection{
		return sections[index]
	}
	
	var sectionCount: Int{
		return sections.count
	}
}
