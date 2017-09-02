//
//  AppDelegate.swift
//  MultipleDetailViews
//
//  Code provided As Is, Do whatever you want with it, but do it at your own risk
//  www.SwiftWala.com
//

import UIKit
import CoreData
import Foundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController?.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self
        let defaults = UserDefaults.standard
        let isPreloaded = defaults.bool(forKey: "isPreloaded")
        if !isPreloaded {
            DispatchQueue.global(qos: .userInitiated).async {
                self.preloadData()
                defaults.set(true, forKey: "isPreloaded")
            }
        }
        reloadCoreData()
        return true
    }
    
    
    func preloadData () {
        let context = CoreDataStack.managedObjectContext
        var currentCategory: String = ""
        var currentSubCategory: String = ""
        var newCategory: Category? = nil
        var newSubCategory: SubCategory? = nil
        for item in listOfItems.items {
            if item.category != currentCategory{
                currentCategory = item.category
                newCategory = NSEntityDescription.insertNewObject(forEntityName: "Category", into: context) as! Category
                newCategory!.setValue(currentCategory, forKey: #keyPath(Category.name))

            }
            if item.subCategory != currentSubCategory{
                currentSubCategory = item.subCategory
                newSubCategory = NSEntityDescription.insertNewObject(forEntityName: "SubCategory", into: context) as! SubCategory
                newSubCategory!.name = currentSubCategory
            }
            
            let itemToSave = NSEntityDescription.insertNewObject(forEntityName: "Item", into: context)
            itemToSave.setValue(item.description, forKey: "item_description")
            itemToSave.setValue(item.measure, forKey: "measure")
            itemToSave.setValue(item.name, forKey: "name")
            itemToSave.setValue(item.price, forKey: "price")
            itemToSave.setValue(item.quantity, forKey: "quantity")
            itemToSave.setValue(item.rarity, forKey: "rarity")
            
            newCategory!.addToItems(itemToSave as! Item)
            newSubCategory!.addToItems(itemToSave as! Item)
        }
        CoreDataStack.saveContext()
        return
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataStack.saveContext()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        CoreDataStack.saveContext()
    }
    
    
    // MARK: - Split view
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController!, onto primaryViewController:UIViewController!) -> Bool {
        if let secondaryAsNavController = secondaryViewController as? UINavigationController {
            if let topAsDetailController = secondaryAsNavController.topViewController as? catalogeDetail {
                if topAsDetailController == nil {
                    // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
                    //If we don't do this, detail1 will open as the first view when run on iPhone, comment and see
                    return true
                }
            }
        }
        else if let secondaryAsNavController = secondaryViewController as? UINavigationController {
            if let topAsDetailController = secondaryAsNavController.topViewController as? MapViewController {
                if topAsDetailController == nil {
                    // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
                    //If we don't do this, detail1 will open as the first view when run on iPhone, comment and see
                    return true
                }
            }
        }
        
        
        
        
        
        
        
        
        return false
        
        
        
        
        
    }
    
    // Correctly Handle Portrait to Landscape transition for iPhone 6+ when TableView2 is open in Portrait. Comment and see for yourself, what happens when you don't write this.
    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        if let primaryAsNavController = primaryViewController as? UINavigationController {
            if (primaryAsNavController.topViewController as? ItemDetailViewController) != nil {
                //Return Navigation controller containing DetailView1 to be used as secondary view for Split View
                return (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detail1Nav") )
            }
            if (primaryAsNavController.topViewController as? MapViewController) != nil {
                //Return Navigation controller containing DetailView1 to be used as secondary view for Split View
                return (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detail1Nav") )
            
            }
            
            
        }
        return nil
    }
    /*
    // MARK: - CORE DATA
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.cadiridris.coreDataTemplate" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "coreDataTemplate", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()*/
    
}


/* domyślny kod
// MARK: - Split view

func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
    guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
    guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
    if topAsDetailController.detailItem == nil {
        // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return true
    }
    return false
}
*/
