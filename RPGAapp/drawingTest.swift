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
            
            for _ in 0...10{
                let setting = self.createRandomDrawSettin(categories: categories, subCategories: subCategoires)
                toTest.drawItems(drawSetting: setting, subCategory: nil, category: nil, reDraw: .not)
            }
        }
    }
    
    func testStressDraw(){
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
        
        for i in 0...100{
            print("test nr:" + String(describing: i))
            
            for cat in categories{
                toTest.drawItems(drawSetting: nil, subCategory: nil, category: cat, reDraw: .not)
            }
            
            for sub in subCategoires{
                toTest.drawItems(drawSetting: nil, subCategory: sub, category: nil, reDraw: .not)
            }
            
            for _ in 0...10{
                let setting = createRandomDrawSettin(categories: categories, subCategories: subCategoires)
                toTest.drawItems(drawSetting: setting, subCategory: nil, category: nil, reDraw: .not)
            }
        }
    }
    
    func createRandomDrawSettin(categories: [RPGAapp.Category], subCategories: [SubCategory]) -> DrawSetting {
        let context = CoreDataStack.managedObjectContext
        
        let drawSetting = NSEntityDescription.insertNewObject(forEntityName: String(describing: DrawSetting.self), into: context) as! DrawSetting
        drawSetting.name = ""
        
        for _ in 0...myRand(5) {
            let newSubDraw = NSEntityDescription.insertNewObject(forEntityName: String(describing: DrawSubSetting.self), into: context) as! DrawSubSetting

            switch myRand(2){
                case 0:
                    let category = categories[myRand(categories.count - 1)]
                    newSubDraw.category = category
                case 1:
                    let subCategory = subCategories[myRand(subCategories.count - 1)]
                    newSubDraw.subCategory = subCategory
                default:
                    break
            }
            
            drawSetting.addToSubSettings(newSubDraw)
        }
        
        CoreDataStack.saveContext()
        return drawSetting
    }
    
}
