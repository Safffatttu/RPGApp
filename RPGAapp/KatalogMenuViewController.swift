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
    
    var filter =  Dictionary<String, Double?>()
    
    override func viewWillAppear(_ animated: Bool) {
        let context = CoreDataStack.managedObjectContext
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(setFilters(_:)))
        NotificationCenter.default.addObserver(self, selector: #selector(reloadFilter(_:)), name: .reloadCatalogeFilter, object: nil)
        
        subCategoryFetch.sortDescriptors = [.sortSubCategoryByCategory,.sortSubCategoryByName]
        do{
            subCategories = try context.fetch(subCategoryFetch) as [SubCategory]
        }
        catch{
            print("error fetching")
        }
        
        categoryFetch.sortDescriptors = [.sortCategoryByName]
        do{
            categories = try context.fetch(categoryFetch) as [Category]
        }
        catch{
            print("error fetching")
        }
        
        super.viewWillAppear(animated)

    }
    
    func reloadFilter(_ notification: Notification){
        let newFilter = notification.object as? Dictionary<String, Double?>
        if newFilter != nil{
            filter = newFilter!
            
        }
    }
    
    func setFilters(_ sender: UIBarButtonItem){
        let filterPopover = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "catalogeFilter") as! catalogeFilterPopover
        
        filterPopover.modalPresentationStyle = .popover

        filterPopover.popoverPresentationController?.sourceView = self.view
            //UIView(frame: CGRect(x: 500, y: 100, width: 300, height: 300))
        if filter.count != 0{
            filterPopover.filter = filter
        }
        
        self.present(filterPopover, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (categories[section].subCategories?.count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catalogeMenuCell")
        let cellSubCategory = categories[indexPath.section].subCategories?.sortedArray(using: [.sortSubCategoryByCategory,.sortSubCategoryByName])[indexPath.row] as! SubCategory
        cell?.textLabel?.text = cellSubCategory.name?.capitalized
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categories[section].name
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToLocation = 0

        let cellSubCategory = categories[indexPath.section].subCategories?.sortedArray(using: [.sortSubCategoryByCategory,.sortSubCategoryByName])[indexPath.row] as! SubCategory
        
        goToLocation = subCategories.index(where: {$0.name == cellSubCategory.name})!
        
        NotificationCenter.default.post(name: .goToSectionCataloge, object: nil)
    }
    
}
extension Notification.Name{
    static let goToSectionCataloge = Notification.Name("goToSectionCataloge")
    static let reloadCatalogeFilter = Notification.Name("reloadCatalogeFilter")
}
