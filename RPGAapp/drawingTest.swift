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
    
    func testFlitering(){
        let itemList = loadItems()
        let cat = catalogeDetail()
        var newItemList = itemList
        cat.filter = randomFilter()
        
        self.measure {
            for _ in 0...100{
                cat.filter = self.randomFilter()
                newItemList = itemList
                cat.filterItemList(newItemList)
            }
        }
    }
    
//    func testFlitering2(){
//        let itemList = loadItems()
//        let cat = catalogeDetail()
//        cat.filter = randomFilter()
//        var newItemList = itemList
//        self.measure {
//            for _ in 0...100{
//                cat.filter = self.randomFilter()
//                newItemList = itemList
//                cat.filterItemInoutList(&newItemList)
//            }
//        }
//    }
    
    func testFlitering3(){
        let itemList = loadItems()
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
        let context = CoreDataStack.managedObjectContext
        let drawSettingsFetch: NSFetchRequest<DrawSetting> = DrawSetting.fetchRequest()
        
        drawSettingsFetch.sortDescriptors = [NSSortDescriptor(key: #keyPath(DrawSetting.name), ascending: true)]
        do{
            drawSettings = try context.fetch(drawSettingsFetch) as [DrawSetting]
        }
        catch{
            print("error")
        }
        
        
        for sett in drawSettings {
            let asd = sett.subSettings?.sortedArray(using: [NSSortDescriptor(key: #keyPath(DrawSubSetting.name), ascending: true)]) as! [DrawSubSetting]
            for i in 0...(asd.count-1) {
                print(asd[i])
            }
        }
    
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
        let items = loadItems()
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
