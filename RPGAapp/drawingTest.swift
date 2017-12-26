//
//  drawingTest.swift
//  
//
//  Created by Jakub on 26.12.2017.
//
//

import XCTest
import CoreData
@testable import RPGAapp

class drawingTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDrawItem(){
        
        let toTest = randomItemMenu()
        let context = CoreDataStack.managedObjectContext

        let categoryFetch: NSFetchRequest<RPGAapp.Category> = Category.fetchRequest()
        
        categoryFetch.sortDescriptors = [.sortCategoryByName]
        var categories: [RPGAapp.Category] = []
        do{
            categories = try context.fetch(categoryFetch)
        }
        catch{
            print("error fetching")
        }
        
        
        let subCategoryFetch: NSFetchRequest<SubCategory> = SubCategory.fetchRequest()
        
        subCategoryFetch.sortDescriptors = [.sortSubCategoryByCategory,.sortSubCategoryByName]
        var subCategoires: [SubCategory] = []
        do{
            subCategoires = try context.fetch(subCategoryFetch)
        }
        catch{
            print("error fetching")
        }
        
        self.measure {
            for cat in categories{
                toTest.drawItems(drawSetting: nil, subCategory: nil, category: cat, reDraw: .not)
            }
            
            for sub in subCategoires{
                toTest.drawItems(drawSetting: nil, subCategory: sub, category: nil, reDraw: .not)
            }
        }
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
