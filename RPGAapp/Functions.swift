//
//  Functions.swift
//  characterGen1
//
//  Created by Jakub on 04.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit


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

func weightedRandom(items: [(item)], weightTotal: UInt) -> item {
    /*function by
     Martin R
     https://codereview.stackexchange.com/questions/112605/weighted-probability-problem-in-swift
     */
    
    precondition(weightTotal > 0, "The sum of the weights must be positive")
    
    let rand = UInt(arc4random_uniform(UInt32(weightTotal)))
    
    var sum = UInt(0)
    for item in items {
        sum += UInt(item.rarity!)
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
            
            
        //categories.last?.2[(categories.last?.2.count)!].1 += 1
        //print (categories.last?.2.count)
        
        categories[categories.count-1].1 = categories[categories.count-1].1 + 1
        listToRet.append(currentItem)
    }
    print("Zakończono ładowanie listy przedmiotów")
    return itemList(items: listToRet, currency: currencyToRet, categories: categories)
}

func forTailingZero(_ temp: Double) -> String{
    var tempVar = String(format: "%g", temp)
    return tempVar
}


