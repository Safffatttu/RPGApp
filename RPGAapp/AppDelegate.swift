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
import Whisper

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    
    var window: UIWindow?
    
    let pack = PackageService()
    let actionDelegate = ActionDelegate()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController?.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self
        let defaults = UserDefaults.standard
        let isPreloaded = defaults.bool(forKey: "isPreloaded")
        if !isPreloaded {
            DispatchQueue.main.async {
                loadItemsFromAsset()
                defaults.set(true, forKey: "isPreloaded")
            }
        }
        
        for setting in settingValues{
            if defaults.value(forKey: setting.key) == nil{
                print(setting)
                defaults.set(setting.value, forKey: setting.key)
            }
        }
        
        pack.delegate = actionDelegate
        return true
    }
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		guard let sessionDictionary = NSDictionary(contentsOf: url) else { return false }
		
		
		guard let newSession = unPackSession(from: sessionDictionary) else { return false }
		Load.sessions().first(where: {$0.current})?.current = false
		newSession.current = true
		
		let action = NSMutableDictionary()
		let actionType = NSNumber(value: ActionType.sessionReceived.hashValue)
		
		action.setValue(actionType, forKey: "action")
		action.setValue(sessionDictionary, forKey: "session")
		action.setValue(newSession.current, forKey: "setCurrent")
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		
		appDelegate.pack.send(action)
		
		NotificationCenter.default.post(name: .sessionReceived, object: nil)
		
		return true
	}
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        let message = Message(title: "Enter your message here.", backgroundColor: .red)
        
        
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers.last as! UINavigationController
        
        Whisper.show(whisper: message, to: navigationController, action: .show)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataStack.saveContext()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        CoreDataStack.saveContext()
    }
    
    // MARK: - Split view
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        
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
        return true
    }
    
    // Correctly Handle Portrait to Landscape transition for iPhone 6+ when TableView2 is open in Portrait. Comment and see for yourself, what happens when you don't write this.
    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        if let primaryAsNavController = primaryViewController as? UINavigationController {
            if (primaryAsNavController.topViewController as? MapViewController) != nil {
                //Return Navigation controller containing DetailView1 to be used as secondary view for Split View
                return (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detail1Nav") )
            
            }
        }
        return nil
    }
}
