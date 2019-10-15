//
//  NameGenerator.swift
//  RPGAapp
//
//  Created by Jakub on 01.07.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import UIKit

class NameGenerator{
	
	static let nameGenerator = NameGenerator()
	
	static let colors: [(String, UIColor)] = [
					("Black", .black),
					("Blue" , .blue),
					("Gray", .green),
					("Red", .red),
					("Yellow", .yellow),
					("Purple", .purple),
					("Brown", .brown)
										]
	
	static func createVisibilityData() -> (String, UIColor){
		let colorsAlreadyUsed = Set(Load.visibilities().map{$0.name!})
		let allColors = Set(self.colors.map{$0.0})
		
		let colorsLeft = allColors.subtracting(colorsAlreadyUsed)
		
		if colorsLeft.count == 0{
			return colors.random()!
		}else{
			if let new =  Array(colorsLeft).random(){
				return colors.first(where: {$0.0 == new})!
			}else{
				return colors.random()!
			}
		}
	}
	
}
