//
//  CurrencyExchange.swift
//  RPGAapp
//
//  Created by Jakub on 19.06.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation

extension Currency{
		
	func show(value: Double) -> String{
		let subCurrencies = self.subCurrency?.array as! [SubCurrency]
		let ratedValue = value * self.rate
		
		var valueToShow = "\(Int(floor(ratedValue))) \((subCurrencies.first)!.name!)"
		
		var reminding = ratedValue - floor(ratedValue)
		
		for sub in subCurrencies.dropFirst().dropLast(){
			let subValueToShow = Int(floor(reminding * Double(sub.rate)))
			
			if subValueToShow != 0{
				let subStrToShow = " \(subValueToShow) \(sub.name!)"
				
				valueToShow += subStrToShow
			}
			
			reminding = (reminding - floor(reminding * Double(sub.rate)) / Double(sub.rate)) * Double(sub.rate)
		}
		
		if subCurrencies.last != nil && subCurrencies.count > 1{
			
			let last = subCurrencies.last!
			
			let lastValue = reminding * Double(last.rate)
			
			if lastValue != 0{
				
				let formatter = NumberFormatter()
				formatter.numberStyle = NumberFormatter.Style.decimal
				formatter.roundingMode = NumberFormatter.RoundingMode.halfUp
				formatter.maximumFractionDigits = 10
				
				if let lastValueString = formatter.string(from: NSNumber(value: lastValue)){
					if lastValueString != "0"{
						let lastToShow = " \(lastValueString) \(last.name!)"
						
						valueToShow += lastToShow
					}
				}
			}
		}
		
		return valueToShow
	}
	
	func valueFrom(string: String)-> Double{
		let subCurrencies = self.subCurrency?.array as! [SubCurrency]
		
		var value: Double = 0.0
		
		for sub in subCurrencies{
			
			let regex = "\\d+.?\\d* \(sub.name!)"
			
			guard let range = string.range(of: regex, options: .regularExpression) else { continue }
			
			let subString = String(string[range].characters.dropLast((sub.name?.characters.count)!))
			guard let subValue = Double(subString) else { continue }
			
			guard let divNumber = subCurrencies.index(where: {$0 === sub}) else { continue }
			
			let absoluteDivider = subCurrencies[0...divNumber].map{$0.rate}.reduce(1, *)
			
			value += (subValue / Double(absoluteDivider))
		}
		
		return value
	}

}

func showPrice(_ value: Double) -> String{
	guard let currency = Load.currentCurrency() else { return "\(value)PLN" }
	
	return currency.show(value: value)
}

func convertCurrencyToValue(_ string: String) -> Double{
	guard let currency = Load.currentCurrency() else { return 0.0 }
	
	return currency.valueFrom(string: string)
}



