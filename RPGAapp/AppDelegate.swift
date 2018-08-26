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
				createBasicCurrency()
            }
        }
        
        for setting in settingValues{
            if defaults.value(forKey: setting.key) == nil{
                print(setting)
                defaults.set(setting.value, forKey: setting.key)
            }
        }
		
		_ = PackageService.pack
		
        return true
    }
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		guard let sessionDictionary = NSDictionary(contentsOf: url) else { return false }
		
		
		guard let newSession = unPackSession(from: sessionDictionary) else { return false }
		Load.sessions().first(where: {$0.current})?.current = false
		newSession.current = true
		
		let action = NSMutableDictionary()
		let actionType = NSNumber(value: ActionType.sessionReceived.rawValue)
		
		action.setValue(actionType, forKey: "action")
		action.setValue(sessionDictionary, forKey: "session")
		action.setValue(newSession.current, forKey: "setCurrent")
		
		PackageService.pack.send(action)
		
		NotificationCenter.default.post(name: .sessionReceived, object: nil)
		NotificationCenter.default.post(name: .reloadTeam, object: nil)
		
		return true
	}
}
