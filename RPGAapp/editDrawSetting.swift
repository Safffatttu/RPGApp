//
//  editDrawSetting.swift
//  RPGAapp
//
//  Created by Jakub on 04.09.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class editDrawSetting: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var setting: DrawSetting? = nil
    
    var categories: [Category] = []
    var subCategories: [SubCategory] = []
    
    let categoryFetch: NSFetchRequest<Category> = Category.fetchRequest()
    let subCategoryFetch: NSFetchRequest<SubCategory> = SubCategory.fetchRequest()
    
    @IBOutlet weak var subSettingsTable: UITableView!
    
    @IBOutlet weak var categoriesTable: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissView(_:)))
        
        if setting == nil{
            let context = CoreDataStack.managedObjectContext
            setting = NSEntityDescription.insertNewObject(forEntityName: String(describing: DrawSetting.self), into: context) as! DrawSetting
        }
        
        super.viewWillAppear(animated)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if tableView == subSettingsTable{
            cell?.textLabel?.text = "asd"
        }
        return cell!
    }
    
    func done(_ sender: UIBarButtonItem){
        
        
        CoreDataStack.saveContext()
        
        dismiss(animated: true, completion: nil)
    }
    
    func dismissView(_ sender: UIBarButtonItem){
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
}
