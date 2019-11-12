//
//  Functions.swift
//  characterGen1
//
//  Created by Jakub on 04.08.2017.
//

import Foundation
import UIKit
import CoreData
import Whisper

func myRand(_ num: Int) -> Int {
    return Int(arc4random_uniform(UInt32(num)))
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

func forTailingZero(_ temp: Double) -> String {
    return String(format: "%g", temp)
}

func loadItemsFromAsset() {
    let context = CoreDataStack.managedObjectContext

    var currentCategory: Category?
    var currentSubCategory: SubCategory?

    let table = NSDataAsset(name: "ITEMS3")
    let decoded = String(data: (table?.data)!, encoding: .utf8)!
    var itemList: [[String]] = []
    let rows = decoded.components(separatedBy: "\n")
    for row in rows {
        let columns = row.components(separatedBy: ";")
        itemList.append(columns)
    }

    var item: Item?

    for line in itemList {
        if line.first == "DATA"{
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
            attribute.rarityMod = Int16(line[5])!
            attribute.id = (attribute.name)! + String(describing: strHash((attribute.name)! + String(describing: attribute.priceMod) + String(describing: (attribute.rarityMod))))
            item?.addToItemAtribute(attribute)
            continue
        }

        item = (NSEntityDescription.insertNewObject(forEntityName: String(describing: Item.self), into: context) as! Item)

        item?.setValue(line[0], forKey: #keyPath(Item.name))
        item?.setValue(line[1], forKey: #keyPath(Item.item_description))
        item?.setValue(Double(line[4]), forKey: #keyPath(Item.price))
        if let rarity = Int16(line[5]) {
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
    var result = UInt64(5381)
    let buf = [UInt8](str.utf8)
    for b in buf {
        result = 127 * (result & 0x00ffffffffffffff) + UInt64(b)
    }
    return result
}


func getCurrentCellIndexPath<T: UIView>(_ sender: T, tableView: UITableView) -> IndexPath? {
    let buttonPosition = (sender as AnyObject).convert(CGPoint.zero, to: tableView)
    if let indexPath: IndexPath = tableView.indexPathForRow(at: buttonPosition) {
        return indexPath
    }
    return nil
}

func whisper(messege: String) {
    let murmur = Murmur(title: messege, backgroundColor: .white, titleColor: .black, font: .systemFont(ofSize: UIFont.systemFontSize), action: nil)
    Whisper.show(whistle: murmur, action: .show(3))
}

func save(dictionary: NSDictionary) -> URL {
	let url = getDocumentsDirectory().appendingPathComponent("session" + String(describing: Date())).appendingPathExtension("rpgs")
	dictionary.write(to: url, atomically: true)

	return url
}

func getDocumentsDirectory() -> URL {
	let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
	return paths[0]
}

@discardableResult
func createCurrencyUsing(name: String, rate: Double, subList: [(String, Int16)]) -> Currency {
	let context = CoreDataStack.managedObjectContext

	let currency = NSEntityDescription.insertNewObject(forEntityName: String(describing: Currency.self), into: context) as! Currency

	currency.name = name

	currency.rate = rate


	for sub in subList {
		let subCurrency = NSEntityDescription.insertNewObject(forEntityName: String(describing: SubCurrency.self), into: context) as! SubCurrency

		subCurrency.name = sub.0
		subCurrency.rate = sub.1

		currency.addToSubCurrency(subCurrency)
	}

	return currency
}

func createTitlesForSubCategory() -> [String: String] {
	var nameDict: [String: String] = [: ]
	let subCategories = Load.subCategories()

	for subCategory in subCategories {
		guard let name = subCategory.name else { continue }
		guard let categoryName = subCategory.category?.name else { continue }
		nameDict[name] = categoryName
	}

	return nameDict
}

func createBasicCurrency() {
	createCurrencyUsing(name: "PLN", rate: 1, subList: [("Zł", 1), ("Gr", 100)])
	createCurrencyUsing(name: "ZkSrM", rate: 1, subList: [("Zk", 1), ("Sr", 12), ("M", 12)])
	CoreDataStack.saveContext()
}

let rarityName = [NSLocalizedString("Junk", comment: ""),
                  NSLocalizedString("Common", comment: ""),
                  NSLocalizedString("Rare", comment: ""),
				  NSLocalizedString("Legendary", comment: "")
	]

func widthForSegmentOfRarityName(num: Int) -> CGFloat {
	guard num < rarityName.count else { return 0.0 }
	let count = rarityName.reduce("", +).count
	let rarityCount = rarityName[num].count

	return CGFloat(rarityCount) / CGFloat(count)
}

extension String {

    func containsIgnoringCase(_ string: String) -> Bool {
        return self.lowercased().replacingOccurrences(of: " ", with: "").contains(string.lowercased())
    }
}

extension UIResponder {

	func next<T: UIResponder>(_ type: T.Type) -> T? {
		return next as? T ?? next?.next(type)
	}
}

extension Notification.Name {
    static let addedItemToPackage = Notification.Name("addedItemToPackage")
	static let addedNote = Notification.Name("newNote")
	static let changedNote = Notification.Name("changedNote")
}

extension NSSortDescriptor {
    static let sortItemByCategory = NSSortDescriptor(key: #keyPath(Item.category), ascending: true)
    static let sortItemBySubCategory = NSSortDescriptor(key: #keyPath(Item.subCategory), ascending: true)
    static let sortItemByName = NSSortDescriptor(key: #keyPath(Item.name), ascending: true)
	static let sortItemByPrice = NSSortDescriptor(key: #keyPath(Item.price), ascending: true)
	static let sortItemByRarity = NSSortDescriptor(key: #keyPath(Item.rarity), ascending: true)

    static let sortItemHandlerByCategory = NSSortDescriptor(key: #keyPath(ItemHandler.item.category), ascending: true)
    static let sortItemHandlerBySubCategory = NSSortDescriptor(key: #keyPath(ItemHandler.item.subCategory), ascending: true)
    static let sortItemHandlerByName = NSSortDescriptor(key: #keyPath(ItemHandler.item.name), ascending: true)

	static let sortItemAtributeByName = NSSortDescriptor(key: #keyPath(ItemAtribute.name), ascending: true)

    static let sortSubCategoryByName = NSSortDescriptor(key: #keyPath(SubCategory.name), ascending: true)
    static let sortSubCategoryByCategory = NSSortDescriptor(key: #keyPath(SubCategory.category), ascending: true)

    static let sortCategoryByName = NSSortDescriptor(key: #keyPath(Category.name), ascending: true)

    static let sortPackageByName = NSSortDescriptor(key: #keyPath(Package.name), ascending: true)
    static let sortPackageById = NSSortDescriptor(key: #keyPath(Package.id), ascending: true)

    static let sortSessionByName = NSSortDescriptor(key: #keyPath(Session.name), ascending: true)

    static let sortCharacterById = NSSortDescriptor(key: #keyPath(Character.id), ascending: true)

	static let sortAbilityByName = NSSortDescriptor(key: #keyPath(Ability.name), ascending: true)

	static let sortSubSettingByName = NSSortDescriptor(key: #keyPath(DrawSubSetting.name), ascending: true)

	static let sortDrawSettingByName = NSSortDescriptor(key: #keyPath(DrawSetting.name), ascending: true)

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

func shakeView(_  view: UIView) {

	let animation = CABasicAnimation(keyPath: "position")
	animation.duration = 0.07
	animation.repeatCount = 4
	animation.autoreverses = true
	animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 10, y: view.center.y))
	animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 10, y: view.center.y))

	view.layer.add(animation, forKey: "position")

}
