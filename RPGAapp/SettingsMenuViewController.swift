//
//  SettingsMenuViewController.swift
//  RPGAapp
//
//  Created by Jakub on 09.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit

var settingValues = [("Auto hide menu",true), ("Change currency",true)]

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
    
    func touchedSwitch(_ sender: UISwitch) {
        if let indexPath = getCurrentCellIndexPath(sender) {
            settingValues[indexPath.row].1 = sender.isOn
            print(settingValues[indexPath.row].0)
            print(settingValues[indexPath.row].1)
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
        cell.settingLabel.text = settingValues[indexPath.row].0
        cell.delegate = self
        return cell
    }
}
