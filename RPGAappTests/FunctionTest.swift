//
//  FunctionTest.swift
//  RPGAappTests
//
//  Created by Jakub Berkop on 31/01/2020.
//  Copyright © 2020 Jakub. All rights reserved.
//

import XCTest
@testable import RPGAapp

class FunctionTest: XCTestCase {

    func testLoadingItems() {
        let contex = CoreDataStack.managedObjectContext
        for item in Load.items() {
            contex.delete(item)
        }
        CoreDataStack.saveContext()
                
        loadItemsFromAsset()
        CoreDataStack.saveContext()
    }
    
    func test_widthForSegmentOfRarityName() {
        _ = widthForSegmentOfRarityName(num: Int(arc4random() % 5))
    }
    
    
    func test_containsIgnoringCase() {
//      Positive case
        XCTAssert("aaaa".containsIgnoringCase("AAa"))
//      Negative case
        XCTAssert(!"aaaa".containsIgnoringCase("BAa"))
    }
    
    func test_getDocumentsDirectory() {
        _ = getDocumentsDirectory()
    }
    
    func test_createTitlesForSubCategory() {
        _ = createTitlesForSubCategory()
    }
    
    func test_packItem() {
        let item = Load.items().randomElement()!
        _ = packItem(item)
    }
    
}
