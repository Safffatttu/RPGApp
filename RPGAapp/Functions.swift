//
//  Functions.swift
//  characterGen1
//
//  Created by Jakub on 04.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Popover
import Whisper
import Dwifft

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

func weightedRandom(items: [Item], weightTotal: Int64) -> Item {
    /*function by
     Martin R
     https://codereview.stackexchange.com/questions/112605/weighted-probability-problem-in-swift
     */
    
    precondition(weightTotal > 0, "The sum of the weights must be positive")
    
    let rand = Int(arc4random_uniform(UInt32(weightTotal)))
    
    var sum = Int(0)
    for item in items {
        sum += Int(item.propability)
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

func forTailingZero(_ temp: Double) -> String{
    return String(format: "%g", temp)
}

func loadItemsFromAsset(){
    let context = CoreDataStack.managedObjectContext
//    var currency: Currency
//    var subCurrency: SubCurrency
	
    var currentCategory: Category? = nil
    var currentSubCategory: SubCategory? = nil
    
    let table = NSDataAsset.init(name: "ITEMS3")
    let decoded = String(data: (table?.data)!, encoding: .utf8)!
    var itemList: [[String]] = []
    let rows = decoded.components(separatedBy: "\n")
    for row in rows {
        let columns = row.components(separatedBy: ";")
        itemList.append(columns)
    }

    var item: Item? = nil
    
    for line in itemList{
        if line.first == "DATA"{
//            currency = NSEntityDescription.insertNewObject(forEntityName: String(describing: Currency.self), into: context) as! Currency
//            currency.name = "Złoty"
//            currency.globalRate = Double(line[2])!
//            
//            subCurrency = NSEntityDescription.insertNewObject(forEntityName: String(describing: SubCurrency.self), into: context) as! SubCurrency
//            subCurrency.name = "PLN"
//            subCurrency.rate = 1
            
            continue
        }
        
        if line.first == "KTG" {
            currentCategory = (NSEntityDescription.insertNewObject(forEntityName: String(describing: Category.self), into: context) as! Category)
            currentCategory?.name = line[1].capitalized
            continue
        }
        
        if line.first == "SUBKTG" {
            currentSubCategory = (NSEntityDescription.insertNewObject(forEntityName: String(describing: SubCategory.self), into: context) as! SubCategory)
            currentSubCategory?.name = line[1].capitalized
            currentSubCategory?.category = currentCategory
            continue
        }
        
        if line.first == "PODITEM"{
            let attribute = NSEntityDescription.insertNewObject(forEntityName: String(describing: ItemAtribute.self), into: context) as! ItemAtribute
            attribute.name = line[3]
            attribute.priceMod = Double(line[4])!
            attribute.rarityMod = Double(line[5])!
            attribute.id = (attribute.name)! + String(describing: strHash((attribute.name)! + String(describing: attribute.priceMod) + String(describing: (attribute.rarityMod))))
            item?.addToItemAtribute(attribute)
            continue
        }
        
        item = (NSEntityDescription.insertNewObject(forEntityName: String(describing: Item.self), into: context) as! Item)
        
        item?.setValue(line[0], forKey: #keyPath(Item.name))
        item?.setValue(line[1], forKey: #keyPath(Item.item_description))
        item?.setValue(Double(line[4]), forKey: #keyPath(Item.price))
        if let rarity = Int16(line[5]){
            if rarity > 0 && rarity < 5 {
                item?.setValue(rarity, forKey: #keyPath(Item.rarity))
            }
        }
        item?.setValue(Int16(line[6]), forKey: #keyPath(Item.quantity))
        item?.setValue(line[7], forKey: #keyPath(Item.measure))
        
        item?.category = currentCategory
        item?.subCategory = currentSubCategory
        
        let id = (item?.name)! + String(describing: strHash((item?.name)! + (item?.item_description)! + String(describing: item?.price)))
        item?.setValue(id, forKey: #keyPath(Item.id))
    }

    CoreDataStack.saveContext()
}

func strHash(_ str: String) -> UInt64 {
    var result = UInt64 (5381)
    let buf = [UInt8](str.utf8)
    for b in buf {
        result = 127 * (result & 0x00ffffffffffffff) + UInt64(b)
    }
    return result
}

func addToEquipment(item: Item, to character: Character, count: Int64 = 1){
    let context = CoreDataStack.managedObjectContext
	
    if let handler = (character.equipment?.first(where: {($0 as! ItemHandler).item == item}) as? ItemHandler){
        handler.count += count
    }else{
        let handler = NSEntityDescription.insertNewObject(forEntityName: String(describing: ItemHandler.self), into: context) as! ItemHandler
		
        handler.item = item
        handler.count = count
        character.addToEquipment(handler)
    }
}

func addToEquipment(itemHandler: ItemHandler, to character: Character){
    let context = CoreDataStack.managedObjectContext
    
    var newHandler = itemHandler
    
    if let handler = (character.equipment?.first(where: {($0 as! ItemHandler).item == itemHandler.item}) as? ItemHandler){
        handler.count += itemHandler.count
    }else{
        newHandler = NSEntityDescription.insertNewObject(forEntityName: String(describing: ItemHandler.self), into: context) as! ItemHandler
        newHandler.item = itemHandler.item
        newHandler.count = itemHandler.count
        
        character.addToEquipment(newHandler)
    }
    
    let atribute = NSEntityDescription.insertNewObject(forEntityName: String(describing: ItemAtributeHandler.self), into: context) as! ItemAtributeHandler
    
    itemHandler.addToItemAtributesHandler(atribute)
}

func add(_ item: Item,to package: Package, count: Int64?){
    let context = CoreDataStack.managedObjectContext

    var itemHandler = package.items?.first(where: {($0 as! ItemHandler).item == item}) as? ItemHandler
    
    if itemHandler == nil{
        itemHandler = NSEntityDescription.insertNewObject(forEntityName: String(describing: ItemHandler.self), into: context) as? ItemHandler
        itemHandler!.item = item
        if count != nil{
            itemHandler!.count = count!
        }
        package.addToItems(itemHandler!)
    }

    else if count != nil{
        itemHandler?.count += count!
    }
    else if (itemHandler?.count)! > 0{
        itemHandler?.count += 1
    }
 
    NotificationCenter.default.post(name: .addedItemToPackage, object: nil)
}

func getCurrentCellIndexPath(_ sender: Any,tableView: UITableView) -> IndexPath? {
    let buttonPosition = (sender as AnyObject).convert(CGPoint.zero, to: tableView)
    if let indexPath: IndexPath = tableView.indexPathForRow(at: buttonPosition) {
        return indexPath
    }
    return nil
}

func getCurrentSession(orCreateNew: Bool = true) -> Session{
    let context = CoreDataStack.managedObjectContext
    let sessionFetch: NSFetchRequest<Session> = Session.fetchRequest()
    sessionFetch.sortDescriptors = [.sortSessionByName]
    var sessions: [Session] = []
    do{
        sessions = try context.fetch(sessionFetch)
    }catch{
        print(error)
    }
    if sessions.count == 0 && orCreateNew{
        let session = NSEntityDescription.insertNewObject(forEntityName: String(describing: Session.self), into: context) as! Session
        session.name = "Sesja"
        session.gameMaster = UIDevice.current.name
        session.current = true
        session.id = String(strHash(session.name! + session.gameMaster! + String(describing: Date())))
		
		let newMap = NSEntityDescription.insertNewObject(forEntityName: String(describing: Map.self), into: context) as! Map
		
		newMap.id = String(strHash(session.id!)) + String(describing: Date())
		newMap.current = true
		
		session.addToMaps(newMap)
		
		CoreDataStack.saveContext()
		
        
        var devices = PackageService.pack.session.connectedPeers.map{$0.displayName}
        devices.append(UIDevice.current.name)
		
        UserDefaults.standard.set(true, forKey: "sessionIsActive")
        
        let action = NSMutableDictionary()
        let actionType = NSNumber(value: ActionType.sessionReceived.rawValue)
        
        action.setValue(actionType, forKey: "action")
		
		let sessionDictionary = packSessionForMessage(session)
		
		action.setValue(actionType, forKey: "action")
		action.setValue(sessionDictionary, forKey: "session")
		action.setValue(session.current, forKey: "setCurrent")
        
		PackageService.pack.send(action)
        NotificationCenter.default.post(name: .addedSession, object: session)
        return session
    }
    
    var currentSession = sessions.first(where: {$0.current == true})
    
    if currentSession == nil{
        currentSession = sessions.first
        currentSession?.current = true
    }
    
    return currentSession!
}

func whisper(messege: String){
    let murmur = Murmur(title: messege, backgroundColor: .white, titleColor: .black, font: .systemFont(ofSize: UIFont.systemFontSize), action: nil)
    Whisper.show(whistle: murmur, action: .show(3))
}

func sessionIsActive(show: Bool = true) -> Bool{
    return true
    let active = UserDefaults.standard.bool(forKey: "sessionIsActive")
    
    if !active && show{
        let message = "Sesja nie jest aktywna"
        whisper(messege: message)
    }
    
    return active
}

func createTempSubCategory(with name: String = "Temp") -> SubCategory {
    let context = CoreDataStack.managedObjectContext
    
    var tempSubCategory: SubCategory?
    let subCategoryFetch: NSFetchRequest<SubCategory> = SubCategory.fetchRequest()
    
    do{
        tempSubCategory = try context.fetch(subCategoryFetch).first(where: {$0.temp})
    }
    catch{
        print("error fetching")
    }
    
    if let subCategory = tempSubCategory{
        return subCategory
        
    }else{
        let subCategory = NSEntityDescription.insertNewObject(forEntityName: String(describing: SubCategory.self), into: context) as! SubCategory
        subCategory.name = name
        subCategory.temp = true
        
        CoreDataStack.saveContext()
        return subCategory
    }
}

func deleteTempSubCategory(){
    let context = CoreDataStack.managedObjectContext
    
    var tempSubCategories: [SubCategory] = []
    let subCategoryFetch: NSFetchRequest<SubCategory> = SubCategory.fetchRequest()
    
    do{
        tempSubCategories = try context.fetch(subCategoryFetch).filter({$0.temp})
    }
    catch{
        print("error fetching")
    }
    for subCat in tempSubCategories{
        context.delete(subCat)
    }
    CoreDataStack.saveContext()
}

func searchCataloge(searchWith string: String = "",using searchModel: [(String,Bool)],sortBy sortModel: [(String,Bool,NSSortDescriptor)]) -> SectionedValues<SubCategory,Item>{
	let searchString = string.replacingOccurrences(of: " ", with: "")
	let searchModel = searchModel.map({$0.1})
	let sortModel = sortModel.filter({$0.1}).map({$0.2})
	
	if searchString == ""{
		return SectionedValues(Load.subCategoriesForCatalog())
		
	}else{
		var itemsToSearch = Load.items()
		
		if !(searchString == "*"){
			itemsToSearch = itemsToSearch.filter({
				(($0.name?.containsIgnoringCase(searchString))! && searchModel[0])
					|| (($0.item_description?.containsIgnoringCase(searchString))! && searchModel[1])
					|| (($0.category?.name?.containsIgnoringCase(searchString))! && searchModel[2])
					|| (($0.subCategory?.name?.containsIgnoringCase(searchString))! && searchModel[3])
					|| (forTailingZero($0.price) == searchString && searchModel[4])
					|| ($0.itemAtribute?.filter({
						(($0 as! ItemAtribute).name?
							.containsIgnoringCase(searchString))!
					}).count != 0  && searchModel[5])
				
			})
		}
		
		itemsToSearch = Array(NSArray(array: itemsToSearch).sortedArray(using: sortModel)) as! [Item]
		
		let searchSubCategory = createTempSubCategory(with: "Wyszukane")
		
		let newSubList: [(SubCategory,[Item])] = [(searchSubCategory,itemsToSearch)]

		return SectionedValues(newSubList)
	}
}

func save(dictionary: NSDictionary)-> URL{
	
	//let randomFilename = UUID().uuidString
	let url = getDocumentsDirectory().appendingPathComponent("session" + String(describing: Date())).appendingPathExtension("rpgs")
	dictionary.write(to: url, atomically: true)
		
	return url
}

func getDocumentsDirectory() -> URL {
	let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
	return paths[0]
}


//let rarityName = ["Dziadostwo", "Normalne", "Rzadkie", "Legendarne"]
let rarityName = ["Junk", "Common", "Rare", "Legendary"]

extension Int{
    init?(_ bool: Bool?) {
        guard bool != nil else {
            return nil
        }
        self = bool! ? 1 : 0
    }
}

extension String {
    
    func containsIgnoringCase(_ string: String) -> Bool{
        return self.lowercased().replacingOccurrences(of: " ", with: "").contains(string.lowercased())
    }
}

extension UIResponder {
	
	func next<T: UIResponder>(_ type: T.Type) -> T? {
		return next as? T ?? next?.next(type)
	}
}

extension Notification.Name{
    static let itemAddedToCharacter = Notification.Name("itemAddedToCharacter")
    static let addedItemToPackage = Notification.Name("addedItemToPackage")
}

extension NSSortDescriptor{
    static let sortItemByCategory = NSSortDescriptor(key: #keyPath(Item.category), ascending: true)
    static let sortItemBySubCategory = NSSortDescriptor(key: #keyPath(Item.subCategory), ascending: true)
    static let sortItemByName = NSSortDescriptor(key: #keyPath(Item.name), ascending: true)
	static let sortItemByPrice = NSSortDescriptor(key: #keyPath(Item.price), ascending: true)
	static let sortItemByRarity = NSSortDescriptor(key: #keyPath(Item.rarity), ascending: true)
	
    static let sortItemHandlerByCategory = NSSortDescriptor(key: #keyPath(ItemHandler.item.category), ascending: true)
    static let sortItemHandlerBySubCategory = NSSortDescriptor(key: #keyPath(ItemHandler.item.subCategory), ascending: true)
    static let sortItemHandlerByName = NSSortDescriptor(key: #keyPath(ItemHandler.item.name), ascending: true)
    
    static let sortSubCategoryByName = NSSortDescriptor(key: #keyPath(SubCategory.name), ascending: true)
    static let sortSubCategoryByCategory = NSSortDescriptor(key: #keyPath(SubCategory.category), ascending: true)
    
    static let sortCategoryByName = NSSortDescriptor(key: #keyPath(Category.name), ascending: true)
    
    static let sortPackageByName = NSSortDescriptor(key: #keyPath(Package.name), ascending: true)
    static let sortPackageById = NSSortDescriptor(key: #keyPath(Package.id), ascending: true)
    
    static let sortSessionByName = NSSortDescriptor(key: #keyPath(Session.name), ascending: true)
    
    static let sortCharacterById = NSSortDescriptor(key: #keyPath(Character.id), ascending: true)
	
	static let sortAbilityByName = NSSortDescriptor(key: #keyPath(Ability.name), ascending: true)
	
}

extension UIApplication {
	
	static func topViewController(base: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController) -> UIViewController? {
		if let nav = base as? UINavigationController {
			return topViewController(base: nav.visibleViewController)
		}
		if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
			return topViewController(base: selected)
		}
		if let presented = base?.presentedViewController {
			return topViewController(base: presented)
		}
		
		return base
	}
}

extension Array{
	
	public func random() -> Element?{
		guard !isEmpty else { return nil }
		let index = Int(arc4random_uniform(UInt32(count)))
		return self[index]
	}
	
}
