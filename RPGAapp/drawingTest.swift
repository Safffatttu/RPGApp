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
        
        let toTest = ItemDrawManager()

        let categories: [RPGAapp.Category] = Load.categories()
        
        let subCategoires: [SubCategory] = Load.subCategories()
        
        self.measure {
            for cat in categories{
                toTest.drawItems(using: cat)
            }
            
            for sub in subCategoires{
                print(sub.name)
                toTest.drawItems(using: sub)
            }
            
            for _ in 0...10{
                let setting = self.createRandomDrawSettin(categories: categories, subCategories: subCategoires)
                toTest.drawItems(using: setting)
            }
        }
    }
    
    func testStressDraw(){
        let toTest = ItemDrawManager()
        
        let categories: [RPGAapp.Category] = Load.categories()
        
        let subCategoires: [SubCategory] = Load.subCategories()
        
        for i in 0...100{
            print("test nr:" + String(describing: i))
            
            for cat in categories{
                toTest.drawItems(using: cat)
            }
            
            for sub in subCategoires{
                toTest.drawItems(using: sub)
            }
            
            for _ in 0...10{
                let setting = createRandomDrawSettin(categories: categories, subCategories: subCategoires)
                toTest.drawItems(using: setting)
            }
        }
    }
    
    func testFlitering(){
        let itemList = Load.items()
        var newItemList = itemList
        
        self.measure {
            for _ in 0...100{
                newItemList = itemList
				
				FilterHelper.filterItemList(newItemList, using: self.randomFilter())
            }
        }
    }
        
    func testFlitering3(){
        let itemList = Load.items()
        let cat = catalogeDetail()
        cat.filter = randomFilter()
        var newItemList = itemList
        self.measure {
            for _ in 0...100{
                let filter = self.randomFilter()
                newItemList = itemList
                self.filterItems(newItemList, filter: filter)
            }
        }
    }
    
    func testDrawSettings(){
        var drawSettings: [DrawSetting] = []
        
        drawSettings = Load.drawSettings()
		
        for sett in drawSettings {
            let asd = sett.subSettings?.sortedArray(using: [NSSortDescriptor(key: #keyPath(DrawSubSetting.name), ascending: true)]) as! [DrawSubSetting]
            for i in 0...(asd.count-1) {
                print(asd[i])
            }
        }
    
    }
    
    func testTempSubCategory(){
        let sub = Load.subCategories()
        print(sub.count)
    }
    
    
    func filterItems(_ items: [Item], filter: [String: Double?]) -> [Item] {
        var itemsToRet = items
        
        let minRarity = filter["minRarity"]
        let maxRarity = filter["maxRarity"]
        let minPrice = filter["minPrice"]
        let maxPrice = filter["maxPrice"]
        
        
        itemsToRet = items.filter({
            $0.rarity >= Int16(minRarity!!) &&
            $0.rarity <= Int16(maxRarity!!) &&
            $0.price >= minPrice!! &&
            $0.price <= maxPrice!!
            })
        
        return itemsToRet
    }
    
    func randomFilter() -> [String: Double?]{
        let items = Load.items()
        var maxPrice: Double = {
            return (items.max { (item1, item2) -> Bool in item1.price < item2.price}?.price)!
        }()
        
        var minPrice: Double = {
            return (items.min { (item1, item2) -> Bool in item1.price < item2.price}?.price)!
        }()
        
        var maxRarity: Double = {
            return Double((items.max { (item1, item2) -> Bool in item1.rarity < item2.rarity}?.rarity)!)
        }()
        
        var minRarity: Double = {
            return Double((items.min { (item1, item2) -> Bool in item1.rarity < item2.rarity}?.rarity)!)
        }()

        maxPrice = Double(myRand(Int(maxPrice)))
        minPrice = Double(myRand(Int(minPrice)))
        
        maxRarity = Double(myRand(Int(maxRarity)))
        minRarity = Double(myRand(Int(minRarity)))
        
        let filter: [String: Double] = ["maxPrice" : maxPrice, "minPrice" : minPrice, "maxRarity": maxRarity, "minRarity" : minRarity]
        return filter
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
