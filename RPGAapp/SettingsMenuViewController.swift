//
//  SettingsMenuViewController.swift
//  RPGAapp
//
//  Created by Jakub on 09.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit


protocol settingCellDelegate {
    
    func touchedSwitch(_ sender: UISwitch)
}

class settingSwitchCell: UITableViewCell{
    
    var delegate: settingCellDelegate?
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        delegate?.touchedSwitch(sender)
    }
    @IBOutlet weak var settingLabel: UILabel!
    
    @IBOutlet weak var settingSwitch: UISwitch!
    
}

let settingValues = ["Auto hide menu": false, "Show price": true, "Dodawaj do listy wylosowanych" : false, "Schowaj menu pakietów" : true]
class SettingMenu: UITableViewController, settingCellDelegate {
    
    @IBOutlet var settingTable: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let keys = Array(UserDefaults.standard.dictionaryWithValues(forKeys: settingValues.map{$0.0}))
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(connectedDevicesChanged), name: .connectedDevicesChanged, object: nil)
    }
    
    func connectedDevicesChanged() {
        settingTable.reloadData()
    }
    
    func touchedSwitch(_ sender: UISwitch) {
        if let indexPath = getCurrentCellIndexPath(sender) {
            UserDefaults.standard.set(sender.isOn, forKey: keys[indexPath.row].key)
            if keys[indexPath.row].key == "Show price" {
                NotificationCenter.default.post(name: .reload, object: nil)
                NotificationCenter.default.post(name: .reloadRandomItemTable, object: nil)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return appDelegate.pack.session.connectedPeers.count > 0 ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return UserDefaults.standard.dictionaryWithValues(forKeys: settingValues.map{$0.0}).count
        }else{
            return appDelegate.pack.session.connectedPeers.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Ustawienia"
        }else{
            return "Połączone urządzenia"
        }
    }
    
    func getCurrentCellIndexPath(_ sender: UISwitch) -> IndexPath? {
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        if let indexPath: IndexPath = tableView.indexPathForRow(at: buttonPosition) {
            return indexPath
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingSwitchCell") as! settingSwitchCell
            cell.settingLabel.text = keys[indexPath.row].key
            cell.settingSwitch.setOn(UserDefaults.standard.bool(forKey: keys[indexPath.row].key), animated: false)
            cell.delegate = self
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell")
            cell?.textLabel?.text = appDelegate.pack.session.connectedPeers[indexPath.row].displayName
            return cell!
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let peer = appDelegate.pack.session.connectedPeers[indexPath.row]
            let action = NSMutableDictionary()
            let actionType: NSNumber = NSNumber(value: ActionType.disconnectPeer.rawValue)
            action.setValue(actionType, forKey: "action")
            action.setValue(peer.displayName, forKey: "peer")
            appDelegate.pack.send(action)
        }
    }
}
extension Notification.Name{
    static let reload = Notification.Name("reload")
}
