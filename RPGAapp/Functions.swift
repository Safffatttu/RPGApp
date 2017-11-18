//
//  Functions.swift
//  characterGen1
//
//  Created by Jakub on 04.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit
import CoreData


func myRand(_ num: Int) -> Int{
    return Int(arc4random_uniform(UInt32(num)))
}


func datatostring() -> String{
    let proTable = NSDataAsset.init(name: "Profesion")
    let dataToDecode = proTable?.data
    return String(data: dataToDecode!, encoding: .utf8)!
    
}

func csv(data: String) -> [[String]] {
    var result: [[String]] = []
    let rows = data.components(separatedBy: "\n")
    for row in rows {
        let columns = row.components(separatedBy: ",")
        result.append(columns)
    }
    return result
}


func weightedRandomElement<T>(items: [(T, UInt)]) -> T {
    /*function by
     Martin R
     https://codereview.stackexchange.com/questions/112605/weighted-probability-problem-in-swift
   */
    let total = items.map { $0.1 }.reduce(0, +)
    precondition(total > 0, "The sum of the weights must be positive")
    
    let rand = UInt(arc4random_uniform(UInt32(total)))
    
    var sum = UInt(0)
    for (element, weight) in items {
        sum += weight
        if rand < sum {
            return element
        }
    }
    fatalError("This should never be reached")
}

func weightedRandom(items: [Item], weightTotal: Int64) -> Item {
    /*function by
     Martin R
     https://codereview.stackexchange.com/questions/112605/weighted-probability-problem-in-swift
     */
    
    precondition(weightTotal > 0, "The sum of the weights must be positive")
    
    let rand = Int(arc4random_uniform(UInt32(weightTotal)))
    
    var sum = Int(0)
    for item in items {
        sum += Int(item.propability)
        if rand < sum {
            return item
        }
    }
    fatalError("This should never be reached")
}

func loadStringTableFromDataAsset(Data: String) -> [[String]]{
    let table = NSDataAsset.init(name: Data)
    let decoded = String(data: (table?.data)!, encoding: .utf8)!
    var result: [[String]] = []
    let rows = decoded.components(separatedBy: "\r")
    for row in rows {
        let columns = row.components(separatedBy: ";")
        result.append(columns)
    }
    return result
}

func tableForWRE(table: [[String?]]) -> [[(Int, UInt)]]{
    var tableToRet = [[(Int, UInt)]] ()
    for i in 0...Int((table.first?.count)! - 2){ //for each race
        print("Race Start\(i)")
        var race = [(Int, UInt)] ()
        for j in 0...59{
            var prof : (Int,UInt)
            if table[j][i]?.rangeOfCharacter(from: CharacterSet.decimalDigits) == nil {
            //if table[j][i] == ""{
                prof = (Int(j),UInt(0))
            }
            else {
                prof = (Int(j),UInt(table[j][i]!)!)
            }
            race.append(prof)
        }
        tableToRet.append(race)
    }
    return tableToRet
}

func changeCurrency(price: Double, currency: [(String,Double)]) -> String{
    var priceToRet = String()

    var currentPrice = (currency.first?.1)! * price
    var toAppend = floor(currentPrice)
    if(toAppend > 0){
        priceToRet.append(forTailingZero(floor(currentPrice)) + (currency.first?.0)!)
    }
    for i in 1...currency.count-1{
        currentPrice = currentPrice * currency[i].1
        toAppend = floor(currentPrice.truncatingRemainder(dividingBy: currency[i].1))
        if( toAppend > 0){
            priceToRet.append(" " + forTailingZero(toAppend) + currency[i].0)
        }
    }
    return priceToRet
}


func loadItemList(data: [[String?]]) -> itemList{
    if(data.first!.first! == "DATA"){
        print("Rozpoczęto ładowanie listy przedmiotów")
    }
    var currencyToRet = [(String,Double)]()
    
    for i in stride(from: 1, to: (data.first?.count)! - 1, by: 2){
        if data.first?[i] == ""{
        continue
        }
        let subCurency = (data.first?[i],Double((data.first?[i+1]!)!))
        /*if currencyToRet.count > 0 {
            currencyToRet[currencyToRet.count - 1].1 *= subCurency.1!
        }*/
        currencyToRet.append(subCurency as! (String, Double))
    }
    

    var listToRet = [item]()
    var currentCategory = String("")
    var currentSubCategory = String()
    
    var categories = [(String,Int, [(String, Int)])] ()

    for i in 1...data.count-2{
        if(data[i].first! == "KTG"){
            currentCategory = (data[i][1])!
            categories.append((currentCategory!,1,[("",001)]))
            currentSubCategory = ""
            continue
        }
        
        if(data[i].first! == "SUBKTG"){
            currentSubCategory = (data[i][1])!
            if(categories[categories.count-1].2.last?.0 == ""){
                categories[categories.count-1].2.removeFirst()
            }
            categories[categories.count-1].2.append((currentSubCategory,1))
            continue
        }
        
        let name = data[i].first!!
        let description = data[i][1]
        let price = Double(data[i][2]!)
        var rarity: UInt? =  UInt(data[i][3]!)
        
        if (rarity == nil || (rarity! >= 0 && rarity! <= 3)){
            rarity = 1
        }
        
        var quantity: Int? = Int(data[i][4]!)
        if(quantity == nil){
            quantity = 0
        }
        
        let measure = data[i][5]
        
        let currentItem = item(name: name, category: currentCategory!, subCategory: currentSubCategory, description: description, price: price, rarity: rarity, quantity: quantity, measure: measure)
        
        categories[categories.count-1].1 = categories[categories.count-1].1 + 1
        listToRet.append(currentItem)
    }
    print("Zakończono ładowanie listy przedmiotów")
    return itemList(items: listToRet, currency: currencyToRet, categories: categories)
}

func forTailingZero(_ temp: Double) -> String{
    return String(format: "%g", temp)
}

func loadItemsFromAsset(){
    let context = CoreDataStack.managedObjectContext
    var currency: Currency
    var subCurrency: SubCurrency
    
    var currentCategory: Category? = nil
    var currentSubCategory: SubCategory? = nil
    
    let table = NSDataAsset.init(name: "ITEMS3")
    let decoded = String(data: (table?.data)!, encoding: .utf8)!
    var itemList: [[String]] = []
    let rows = decoded.components(separatedBy: "\n")
    for row in rows {
        let columns = row.components(separatedBy: ";")
        itemList.append(columns)
    }

    var item: Item? = nil
    
    for line in itemList{
        if line.first == "DATA"{
            currency = NSEntityDescription.insertNewObject(forEntityName: String(describing: Currency.self), into: context) as! Currency
            currency.name = "Złoty"
            currency.globalRate = Double(line[2])!
            
            subCurrency = NSEntityDescription.insertNewObject(forEntityName: String(describing: SubCurrency.self), into: context) as! SubCurrency
            subCurrency.name = "PLN"
            subCurrency.rate = 1
            
            continue
        }
        
        if line.first == "KTG" {
            currentCategory = (NSEntityDescription.insertNewObject(forEntityName: String(describing: Category.self), into: context) as! Category)
            currentCategory?.name = line[1].capitalized
            continue
        }
        
        if line.first == "SUBKTG" {
            currentSubCategory = (NSEntityDescription.insertNewObject(forEntityName: String(describing: SubCategory.self), into: context) as! SubCategory)
            currentSubCategory?.name = line[1].capitalized
            currentSubCategory?.category = currentCategory
            continue
        }
        
        if line.first == "PODITEM"{
            let attribute = NSEntityDescription.insertNewObject(forEntityName: String(describing: ItemAtribute.self), into: context) as! ItemAtribute
            attribute.name = line[3]
            attribute.priceMod = Double(line[4])!
            attribute.rarityMod = Double(line[5])!
            attribute.id = (attribute.name)! + String(describing: strHash((attribute.name)! + String(describing: attribute.priceMod) + String(describing: (attribute.rarityMod))))
            item?.addToItemAtribute(attribute)
            continue
        }
        
        item = (NSEntityDescription.insertNewObject(forEntityName: String(describing: Item.self), into: context) as! Item)
        
        item?.setValue(line[0], forKey: #keyPath(Item.name))
        item?.setValue(line[1], forKey: #keyPath(Item.item_description))
        item?.setValue(Double(line[4]), forKey: #keyPath(Item.price))
        if let rarity = Int16(line[5]){
            if rarity > 0 && rarity < 5 {
                item?.setValue(rarity, forKey: #keyPath(Item.rarity))
            }
        }
        item?.setValue(Int16(line[6]), forKey: #keyPath(Item.quantity))
        item?.setValue(line[7], forKey: #keyPath(Item.measure))
        
        item?.category = currentCategory
        item?.subCategory = currentSubCategory
        
        let id = (item?.name)! + String(describing: strHash((item?.name)! + (item?.item_description)! + String(describing: item?.price)))
        item?.setValue(id, forKey: #keyPath(Item.id))
    }

    CoreDataStack.saveContext()
}

func strHash(_ str: String) -> UInt64 {
    var result = UInt64 (5381)
    let buf = [UInt8](str.utf8)
    for b in buf {
        result = 127 * (result & 0x00ffffffffffffff) + UInt64(b)
    }
    return result
}

func addToEquipment(item: Item, toCharacter: Character) -> Bool{
    let context = CoreDataStack.managedObjectContext
    var newHandler = false
    
    let filter = NSPredicate(format: "item == %@", item)

    let handlers = toCharacter.equipment?.filtered(using: filter)
    
    let itemHandler: ItemHandler
    
    if handlers?.count == 0{
        itemHandler = NSEntityDescription.insertNewObject(forEntityName: String(describing: ItemHandler.self), into: context) as! ItemHandler
        itemHandler.item = item
        
        toCharacter.addToEquipment(itemHandler)
        newHandler = true
    }
    else{
        itemHandler = handlers?.first as! ItemHandler
        itemHandler.count += 1
    }
    
    let atribute = NSEntityDescription.insertNewObject(forEntityName: String(describing: ItemAtributeHandler.self), into: context) as! ItemAtributeHandler
    
    itemHandler.addToItemAtributesHandler(atribute)
    
    return newHandler
}

func add(_ item: Item,to package: Package, count: Int64?){
    let context = CoreDataStack.managedObjectContext

    var itemHandler = package.items?.first(where: {($0 as! ItemHandler).item == item}) as? ItemHandler
    
    if itemHandler == nil{
        itemHandler = NSEntityDescription.insertNewObject(forEntityName: String(describing: ItemHandler.self), into: context) as? ItemHandler
        itemHandler!.item = item
        if count != nil{
            itemHandler!.count = count!
        }
        package.addToItems(itemHandler!)
    }

    else if count != nil{
        itemHandler?.count += count!
    }
    else if (itemHandler?.count)! > 0{
        itemHandler?.count += 1
    }
 
    NotificationCenter.default.post(name: .addedItemToPackage, object: nil)
}

extension Notification.Name{
    static let itemAddedToCharacter = Notification.Name("itemAddedToCharacter")
    static let addedItemToPackage = Notification.Name("addedItemToPackage")
}

extension NSSortDescriptor{
    static let sortItemByCategory = NSSortDescriptor(key: #keyPath(Item.category), ascending: true)
    static let sortItemBySubCategory = NSSortDescriptor(key: #keyPath(Item.subCategory), ascending: true)
    static let sortItemByName = NSSortDescriptor(key: #keyPath(Item.name), ascending: true)
    
    static let sortItemHandlerByCategory = NSSortDescriptor(key: #keyPath(ItemHandler.item.category), ascending: true)
    static let sortItemHandlerBySubCategory = NSSortDescriptor(key: #keyPath(ItemHandler.item.subCategory), ascending: true)
    static let sortItemHandlerByName = NSSortDescriptor(key: #keyPath(ItemHandler.item.name), ascending: true)
    
    static let sortSubCategoryByName = NSSortDescriptor(key: #keyPath(SubCategory.name), ascending: true)
    static let sortSubCategoryByCategory = NSSortDescriptor(key: #keyPath(SubCategory.category), ascending: true)
    
    static let sortCategoryByName = NSSortDescriptor(key: #keyPath(Category.name), ascending: true)
    
    static let sortPackageByName = NSSortDescriptor(key: #keyPath(Category.name), ascending: true)
}


let sortItemByCategory = NSSortDescriptor(key: #keyPath(Item.category), ascending: true)
let sortItemBySubCategory = NSSortDescriptor(key: #keyPath(Item.subCategory), ascending: true)
let sortItemByName = NSSortDescriptor(key: #keyPath(Item.name), ascending: true)

let sortItemHandlerByCategory = NSSortDescriptor(key: #keyPath(ItemHandler.item.category), ascending: true)
let sortItemHandlerBySubCategory = NSSortDescriptor(key: #keyPath(ItemHandler.item.subCategory), ascending: true)
let sortItemHandlerByName = NSSortDescriptor(key: #keyPath(ItemHandler.item.name), ascending: true)

let sortSubCategoryByName = NSSortDescriptor(key: #keyPath(SubCategory.name), ascending: true)
let sortSubCategoryByCategory = NSSortDescriptor(key: #keyPath(SubCategory.category), ascending: true)

let sortCategoryByName = NSSortDescriptor(key: #keyPath(Category.name), ascending: true)

let sortPackageByName = NSSortDescriptor(key: #keyPath(Category.name), ascending: true)
