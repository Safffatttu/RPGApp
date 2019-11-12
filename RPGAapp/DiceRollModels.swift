//
//  DiceThrowing.swift
//  RPGAapp
//
//  Created by Jakub on 13.05.2018.
//

import Foundation

public struct DiceModel {
	public static func ADNormal(_ n: Int) -> Int {
		let roll = rollDices(n)
		let numOf6 = countOccurances(roll, 6)
	
		var wynik: Int
	
		if numOf6 > 1 {
			wynik = numOf6 + 5
		} else {
			wynik = roll.max()!
		}
		return wynik
	}

	public static func ADTo6(_ n: Int) -> Int {
		var roll = rollDices(n)
	
		for i in 2...5 {
			roll = stack(roll, i)
		}
	
		let numOf6 = countOccurances(roll, 6)
		var wynik: Int
	
		if numOf6 > 1 {
			wynik = numOf6 + 5
		} else {
			wynik = roll.max()!
		}
		return wynik
	}

	public static func AD2UP(_ n: Int) -> Int {
		let roll = rollDices(n)
		let max = roll.max()!
	
		if max == 1 {
			return 1
		}
	
		let rollBez2 = roll.filter({$0 != 1})
	
		var stackedRoll: [Int] = rollBez2
	
		var i = 2
		while true {

			stackedRoll = stack(stackedRoll, i)

			let max = stackedRoll.max()!
			if max <= i {
				break
			}

			i += 1
		}
	
		return stackedRoll.max()!
	}

	public static func ADNormalRH(_ n: Int) -> Int {
		var roll = rollDices(n)
		let numOf6 = countOccurances(roll, 6)
		let countOf1 = countOccurances(roll, 1)
	
		var wynik: Int
	
        removeItems(&roll, n: 1, countOf1)
	
		decrementHighest(&roll, times: countOf1 / 2)
	
		if numOf6 > 1 {
			wynik = numOf6 + 5
		} else {
			wynik = roll.max()!
		}
		return wynik
	}

	public static let allModels: [((Int) -> Int, String)] = [
		(DiceModel.ADNormal(_:), "ADNormal"),
		(DiceModel.AD2UP(_:), "AD2UP"),
		(DiceModel.ADTo6(_:), "ADTo6")]

}
