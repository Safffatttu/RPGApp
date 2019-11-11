//
//  DiceThrowingFunctions.swift
//  RPGAapp
//
//  Created by Jakub on 13.05.2018.
//

import Foundation

func d(_ n: Int) -> Int {
	return myRand(n) + 1
}

func avg(_ array: [Int]) -> Double {
	var sum: Double = 0
	for i in array {
		sum += Double(i)
	}

	return Double(sum) / Double(array.count)
}

func stack(_ array: [Int], _ n: Int) -> [Int] {
	var a = array

	var ocurances = countOccurances(array, n)

	if ocurances == 0 {
		return a
	}

	while ocurances >= 2 {
		let indexA = a.firstIndex(of: n)
		a.remove(at: indexA!)
		let indexB = a.firstIndex(of: n)
		a[indexB!] += 1
		ocurances -= 2
	}

	return a
}


public func countOccurances(_ array: [Int], _ number: Int) -> Int {
	return array.filter({$0 == number}).count
}

func rollDices(_ count: Int, ofType: Int = 6) -> [Int] {
	var array: [Int] = []

	for _ in 0...count - 1 {
		let diceRoll = myRand(ofType) + 1
		array.append(diceRoll)
	}

	return array
}


func removeItems(_ a: inout [Int], n: Int, _ c: Int) {
	for _ in 0...c - 1 {
		if let index = a.firstIndex(of: n) {
			a.remove(at: index)
		} else {
			break
		}
	}
}

func decrementHighest(_ a: inout [Int], times c: Int) {
	for _ in 0...c - 1 {
		guard let max = a.max() else {
			return
		}
	
		guard max != 0 else {
			return
		}
	
		guard let indexOfMax = a.firstIndex(of: max) else {
			break
		}
	
		a[indexOfMax] -= 1
	}
}
