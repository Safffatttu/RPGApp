//
//  SettingsMenuViewController.swift
//  RPGAapp
//
//  Created by Jakub on 09.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit

class SettingMenu: UITableViewController {
    
    let settingItems = [("Auto hide menu","menuSwitchCell"), ("CustomSliderControll","menuSliderCell")]
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: settingItems[indexPath.row].1)
        cell?.textLabel?.text = settingItems[indexPath.row].0
        
        return cell!
        
    }
    
    
    
}
