//
//  SettingsMenuViewController.swift
//  RPGAapp
//
//  Created by Jakub on 09.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol settingCellDelegate {
    
    func touchedSwitch(_ sender: UISwitch)
    
    func pressedButton(_ sender: UIButton)
}

class settingSwitchCell: UITableViewCell{
    
    var delegate: settingCellDelegate?
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        delegate?.touchedSwitch(sender)
    }
    @IBOutlet weak var settingLabel: UILabel!
    
    @IBOutlet weak var settingSwitch: UISwitch!
}

class settingButtonCell: UITableViewCell{
    
    var delegate: settingCellDelegate?
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        delegate?.pressedButton(sender)
    }
    
    @IBOutlet weak var settingLabel: UILabel!
    
    @IBOutlet weak var settingButton: UIButton!
}

let settingValues = ["Auto hide menu": false, "Show price": true, "Dodawaj do listy wylosowanych" : false, "Schowaj menu pakietów" : true, "sessionIsActive": true, "syncSessionRemoval": false]

class SettingMenu: UITableViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let keys = Array(UserDefaults.standard.dictionaryWithValues(forKeys: settingValues.map{$0.0}))
    
    var sessions: [Session] = Load.sessions()
	
	var documenController:UIDocumentInteractionController!
	
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(connectedDevicesChanged), name: .connectedDevicesChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchedSessionAction(_:)), name: .switchedSession, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionDeleted(_:)), name: .sessionDeleted, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(sessionReceived), name: .sessionReceived, object: nil)
		
        super.viewWillAppear(animated)
    }
	
	func sessionReceived() {
		sessions = Load.sessions()
		tableView.reloadData()
	}
	
    func switchedSessionAction(_ notification: Notification){
        let action = notification.object as? NSMutableDictionary
        let sessionId = action?.value(forKey: "sessionId") as? String
        
        let index = sessions.index(where: {$0.id == sessionId})
        guard index != nil else {
			sessionReceived()
			return
        }
        let indexPath = IndexPath(row: index! + 1, section: 1)
        
        switchedSession(indexPath: indexPath)
    }
    
    func switchedSession(indexPath: IndexPath){
        let previousIndex = self.sessions.index(where: {$0.current == true})
        var indexesToReload = [indexPath]
        if previousIndex != nil{
            sessions[previousIndex!].current = false
            indexesToReload.append(IndexPath(row: previousIndex! + 1, section: 1))
        }
        sessions[indexPath.row - 1].current = true
        
        self.tableView.reloadRows(at: indexesToReload, with: .automatic)
		
		NotificationCenter.default.post(name: .reloadTeam, object: nil)
    }
    
    func sessionDeleted(_ notification: Notification){
        let index = notification.object as! IndexPath
        sessions = Load.sessions()
        tableView.deleteRows(at: [index], with: .automatic)
    }
    
    func connectedDevicesChanged() {
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return appDelegate.pack.session.connectedPeers.count > 0 ? 3 : 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return UserDefaults.standard.dictionaryWithValues(forKeys: settingValues.map{$0.0}).count + 1
        }else if section == 1{
            return 1 + sessions.count
        }else{
            return appDelegate.pack.session.connectedPeers.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Ustawienia"
        }else if section == 1{
            return "Sesje"
        }else {
            return "Połączone urządzenia"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
			if indexPath.row < settingValues.count{
				let cell = tableView.dequeueReusableCell(withIdentifier: "settingSwitchCell") as! settingSwitchCell
				cell.settingLabel.text = keys[indexPath.row].key
				cell.settingSwitch.setOn(UserDefaults.standard.bool(forKey: keys[indexPath.row].key), animated: false)
				cell.delegate = self
				cell.selectionStyle = .none
				return cell
			}else {
				let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell")
				
				cell?.textLabel?.text = "Sync item database"
				
				return cell!
			}
        }else if indexPath.section == 1 {
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! settingButtonCell
                cell.settingLabel?.text = "Nowa sesja"
                cell.selectionStyle = .none
                cell.settingButton.setTitle("Dodaj", for: .normal)
                cell.delegate = self
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell")
                cell?.textLabel?.text = sessions[indexPath.row - 1].name! + " " + String((sessions[indexPath.row - 1].id?.characters.suffix(4))!)
                cell?.selectionStyle = .none
                cell?.accessoryType = .none
                if sessions[indexPath.row - 1].current{
                    cell?.accessoryType = .checkmark
                }
				
                return cell!
            }
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell")
            cell?.textLabel?.text = appDelegate.pack.session.connectedPeers[indexPath.row].displayName
            cell?.selectionStyle = .none
            
            return cell!
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 0 && indexPath.row == settingValues.count{
			let syncAction = NSMutableDictionary()
			syncAction.setValue(ActionType.syncItemLists, forKey: "action")
			
			let requestAction = NSMutableDictionary()
			requestAction.setValue(ActionType.requestedItemList.rawValue, forKey: "action")
			
			self.appDelegate.pack.send(syncAction)
			self.appDelegate.pack.send(requestAction)
		}
		if indexPath.section == 1 && indexPath.row > 0 && !sessions[indexPath.row - 1].current{
            let alert = UIAlertController(title: nil, message: "Do you want to change session", preferredStyle: .alert)
			
            let alertYes = UIAlertAction(title: "Tak", style: .destructive, handler: {(alert: UIAlertAction!) -> Void in
                self.switchedSession(indexPath: indexPath)
                
                let action = NSMutableDictionary()
                let actionType = NSNumber(value: ActionType.sessionSwitched.rawValue)
                
                action.setValue(actionType, forKey: "action")
                action.setValue(self.sessions[indexPath.row - 1].id, forKey: "sessionId")
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                appDelegate.pack.send(action)
            })
            
            let alertNo = UIAlertAction(title: "Nie", style: .cancel, handler: nil)
            
            alert.addAction(alertYes)
            alert.addAction(alertNo)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return indexPath.section == 2 || (indexPath.section == 1 && indexPath.row != 0)
    }
	
	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		var actions: [UITableViewRowAction]?
		
		if indexPath.section == 1{
			actions = []
			let removeSession = UITableViewRowAction(style: .destructive, title: "Delete", handler: {action,path in
			
				let alert = UIAlertController(title: nil, message: "Do you want to delet this session?", preferredStyle: .alert)
				
				let alertYes = UIAlertAction(title: "Yes", style: .destructive, handler: { (_) -> Void in
					
					let context = CoreDataStack.managedObjectContext
					let session = self.sessions[path.row - 1]
					let sessionId = session.id
					self.sessions.remove(at: path.row - 1)
					
					tableView.deleteRows(at: [path], with: .automatic)
					
					context.delete(session)
					CoreDataStack.saveContext()
					
					let action = NSMutableDictionary()
					let actionType: NSNumber = NSNumber(value: ActionType.sessionDeleted.rawValue)
					action.setValue(actionType, forKey: "action")
					action.setValue(sessionId, forKey: "sessionId")
					self.appDelegate.pack.send(action)
				})
				
				let alertNo = UIAlertAction(title: "No", style: .cancel, handler: nil)
				
				alert.addAction(alertYes)
				alert.addAction(alertNo)
				
				self.present(alert, animated: true, completion: nil)
			})
				
			actions?.append(removeSession)
		
			let sendSession = UITableViewRowAction(style: .normal, title: "Send", handler: {action,path in
				
				let session = self.sessions[path.row - 1]
				let sessionDict = packSessionForMessage(session)
				
				let action = NSMutableDictionary()
				let actionType = NSNumber(value: ActionType.sessionReceived.rawValue)
				
				action.setValue(actionType, forKey: "action")
				action.setValue(sessionDict, forKey: "session")
				
				let appDelegate = UIApplication.shared.delegate as! AppDelegate
				
				appDelegate.pack.send(action)

				tableView.setEditing(false, animated: true)
				whisper(messege: "Send session")
			})
			
			actions?.append(sendSession)
			
			let shareSession = UITableViewRowAction(style: .normal, title: "Share", handler: {action,path in
				guard self.sessions.count > indexPath.row - 1 && indexPath.row - 1 >= 0  else { return }
				
				let dict = packSessionForMessage(self.sessions[indexPath.row - 1])
				let url = save(dictionary: dict)
				
				self.documenController = UIDocumentInteractionController(url: url)
				
				let touchPoint = tableView.rectForRow(at: path)
				self.documenController.presentOptionsMenu(from: touchPoint, in: tableView, animated: true)
			})
			
			shareSession.backgroundColor = UIColor.darkGray
			
			actions?.append(shareSession)
			
		}else{
			actions = []
			let removePeer = UITableViewRowAction(style: .destructive, title: "Remove", handler: {action,path in
				
				let peer = self.appDelegate.pack.session.connectedPeers[path.row]
				let action = NSMutableDictionary()
				let actionType: NSNumber = NSNumber(value: ActionType.disconnectPeer.rawValue)
				
				action.setValue(actionType, forKey: "action")
				action.setValue(peer.displayName, forKey: "peer")
				
				self.appDelegate.pack.send(action)
				self.appDelegate.pack.session.cancelConnectPeer(peer)
			})
			actions?.append(removePeer)
		}
		
		return actions
	}
	
}

extension SettingMenu: settingCellDelegate {
    
    func touchedSwitch(_ sender: UISwitch) {
        if let indexPath = getCurrentCellIndexPath(sender, tableView: self.tableView) {
            UserDefaults.standard.set(sender.isOn, forKey: keys[indexPath.row].key)
            if keys[indexPath.row].key == "Show price" {
                NotificationCenter.default.post(name: .reloadRandomItemTable, object: nil)
            }
        }
    }
    
    func pressedButton(_ sender: UIButton) {
        let context = CoreDataStack.managedObjectContext
        let session = NSEntityDescription.insertNewObject(forEntityName: String(describing: Session.self), into: context) as! Session
        session.name = "Sesja"
        session.gameMaster = UIDevice.current.name
        session.current = true
        session.id = String(strHash(session.name! + session.gameMaster! + String(describing: Date())))
		
		let newMap = NSEntityDescription.insertNewObject(forEntityName: String(describing: Map.self), into: context) as! Map
		
		newMap.id = String(strHash(session.id!)) + String(describing: Date())
		newMap.current = true
		
		session.addToMaps(newMap)
		
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        var devices = appDelegate.pack.session.connectedPeers.map{$0.displayName}
        devices.append(UIDevice.current.name)
        
        session.devices = NSSet(array: devices)
        
        let previous = sessions.index(where: {$0.current == true})
        if previous != nil{
            sessions[previous!].current = false
        }
        
        let index = IndexPath(row: tableView(self.tableView, numberOfRowsInSection: 1), section: 1)
        sessions.append(session)
        
        self.tableView.insertRows(at: [index], with: .automatic)
        
        if previous != nil{
            let previousIndex = IndexPath(row: previous! + 1, section: 1)
            self.tableView.reloadRows(at: [previousIndex], with: .automatic)
        }
        CoreDataStack.saveContext()
        
        let action = NSMutableDictionary()
		let actionType = NSNumber(value: ActionType.sessionReceived.rawValue)
		
		action.setValue(actionType, forKey: "action")
		
		let sessionDictionary = packSessionForMessage(session)
		
		action.setValue(actionType, forKey: "action")
		action.setValue(sessionDictionary, forKey: "session")
		action.setValue(session.current, forKey: "setCurrent")
		
		appDelegate.pack.send(action)
    }
}

extension Notification.Name{
    static let reload = Notification.Name("reload")
    static let addedSession = Notification.Name("addedSession")
    static let switchedSession = Notification.Name("switchedSession")
    static let sessionDeleted = Notification.Name("sessionDeleted")
	static let sessionReceived = Notification.Name("sessionReceived")
}
