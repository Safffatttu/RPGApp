//
//  KatalogMenuViewController.swift
//  RPGAapp
//
//  Created by Jakub on 09.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit
import CoreData

var goToLocation =  Int()

class catalogeMenu: UITableViewController {
    
    var categories: [Category] = []
    var subCategories: [SubCategory] = []
    
    let categoryFetch: NSFetchRequest<Category> = Category.fetchRequest()
    let subCategoryFetch: NSFetchRequest<SubCategory> = SubCategory.fetchRequest()
    
    override func viewDidLoad() {
        
        let context = CoreDataStack.managedObjectContext
        
        subCategoryFetch.sortDescriptors = [sortSubCategoryByCategory,sortSubCategoryByName]
        do{
            subCategories = try context.fetch(subCategoryFetch) as [SubCategory]
        }
        catch{
            print("error fetching")
        }
        
        categoryFetch.sortDescriptors = [sortCategoryByName]
        do{
            categories = try context.fetch(categoryFetch) as [Category]
        }
        catch{
            print("error fetching")
        }
        
        print(subCategories.map({$0.name}))
        
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (categories[section].subCateogories?.count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catalogeMenuCell")
        let cellSubCategory = categories[indexPath.section].subCateogories?.sortedArray(using: [sortSubCategoryByCategory,sortSubCategoryByName])[indexPath.row] as! SubCategory
        cell?.textLabel?.text = cellSubCategory.name?.capitalized
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categories[section].name
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToLocation = 0

        let cellSubCategory = categories[indexPath.section].subCateogories?.sortedArray(using: [sortSubCategoryByCategory,sortSubCategoryByName])[indexPath.row] as! SubCategory
        
        goToLocation = subCategories.index(where: {$0.name == cellSubCategory.name})!
        
        NotificationCenter.default.post(name: .goToSectionCataloge, object: nil)
    }
    
}
extension Notification.Name{
    static let goToSectionCataloge = Notification.Name("goToSectionCataloge")
}

