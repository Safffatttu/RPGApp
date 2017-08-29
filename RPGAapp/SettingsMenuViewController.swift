//
//  SettingsMenuViewController.swift
//  RPGAapp
//
//  Created by Jakub on 09.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit

//var settingValues = [("Auto hide menu",true), ("Change currency",true)]

var settingValues = ["Auto hide menu": false, "Show price": true, "Dodawaj do listy wylosowanych" : false]

protocol settingCellDelegate {
    
    func touchedSwitch(_ sender: UISwitch)
}

class settingMenuCell: UITableViewCell{
    
    var delegate: settingCellDelegate?
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        delegate?.touchedSwitch(sender)
    }
    @IBOutlet weak var settingLabel: UILabel!
    
    @IBOutlet weak var settingSwitch: UISwitch!
    
}

class SettingMenu: UITableViewController, settingCellDelegate {
    let keys = Array(settingValues.keys)
    
    func touchedSwitch(_ sender: UISwitch) {
        if let indexPath = getCurrentCellIndexPath(sender) {
            settingValues[keys[indexPath.row]] = sender.isOn
            print(keys[indexPath.row])
            if keys[indexPath.row] == "Show price" {
                NotificationCenter.default.post(name: .reload, object: nil)
                NotificationCenter.default.post(name: .reloadRandomItemTable, object: nil)
            }
        }
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingValues.count
    }
    
    func getCurrentCellIndexPath(_ sender: UISwitch) -> IndexPath? {
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        if let indexPath: IndexPath = tableView.indexPathForRow(at: buttonPosition) {
            return indexPath
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as! settingMenuCell
        cell.settingLabel.text = keys[indexPath.row]
        cell.settingSwitch.setOn(settingValues[keys[indexPath.row]]!, animated: false)
        cell.delegate = self
        return cell
    }
}
extension Notification.Name{
    static let reload = Notification.Name("reload")
}
