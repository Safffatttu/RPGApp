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

protocol CatalogeModelSection: class{
	var name: String { get }
	subscript(index: Int) -> CatalogeModelItem { get }
	
	func select(index: Int) -> Void
	var count: Int { get }
}

protocol CatalogeModelItem: class{
	var name: String { get }
	var selected: Bool { get }
}

final class CatalogeSearchItem: CatalogeModelItem{
	fileprivate(set) var name: String
	fileprivate(set) var selected: Bool
	
	init(name: String, selected: Bool){
		self.name = name
		self.selected = selected
	}
}

final class CatelogeSortItem: CatalogeModelItem{
	fileprivate(set) var name: String
	fileprivate(set) var selected: Bool
	fileprivate(set) var type: SortType
	
	init(name: String, selected: Bool, type: SortType){
		self.name = name
		self.selected = selected
		self.type = type
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
	}
}

final class CatalogeModel{

	private var sections: [CatalogeModelSection]{
		return [sortModel, searchModel]
	}
	
	private(set) var sortModel: CatalogeSortSection
	private(set) var searchModel: CatalogeSearchSection
	
	init(sortSection: CatalogeSortSection, searchSection: CatalogeSearchSection) {
		self.sortModel = sortSection
		self.searchModel = searchSection
	}
	
	subscript(index: Int) -> CatalogeModelSection{
		return sections[index]
	}
	
}
