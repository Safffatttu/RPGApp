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
	
    let keys = Array(UserDefaults.standard.dictionaryWithValues(forKeys: settingValues.map{$0.0}))
    
	var sessions: [Session] = Load.sessions()
	
	var currencies: [Currency] = Load.currencies()
	
	var visibilities: [Visibility] = Load.visibilities()
	
	var documenController:UIDocumentInteractionController!
	
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(connectedDevicesChanged), name: .connectedDevicesChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchedSessionAction(_:)), name: .switchedSession, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionDeleted(_:)), name: .sessionDeleted, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(sessionReceived), name: .sessionReceived, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(currencyCreated), name: .currencyCreated, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(visibilityCreated), name: .visibilityCreated, object: nil)
		
        super.viewWillAppear(animated)
    }
	
	func sessionReceived() {
		sessions = Load.sessions()
		tableView.reloadData()
	}
	
	func currencyCreated(){
		currencies = Load.currencies()
		let index = IndexSet(integer: 2)
		tableView.reloadSections(index, with: .automatic)
	}
	
	func visibilityCreated(){
		visibilities = Load.visibilities()
		let index = IndexSet(integer: 3)
		tableView.reloadSections(index, with: .automatic)
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
			for session in sessions{
				session.current = false
			}
			
            indexesToReload.append(IndexPath(row: previousIndex! + 1, section: 1))
        }
		
        sessions[indexPath.row - 1].current = true
		
		CoreDataStack.saveContext()
		
		visibilities = Load.visibilities()
		
		let currencySection = IndexSet(integer: 2)
		let visiblitySection = IndexSet(integer: 3)
		
		tableView.beginUpdates()
		
		tableView.reloadRows(at: indexesToReload, with: .fade)
		tableView.reloadSections(currencySection, with: .fade)
		tableView.reloadSections(visiblitySection, with: .automatic)
		
		tableView.endUpdates()
		
		sessions = Load.sessions()
		
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
        return PackageService.pack.session.connectedPeers.count > 0 ? 5 : 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return UserDefaults.standard.dictionaryWithValues(forKeys: settingValues.map{$0.0}).count + 1
        }else if section == 1{
            return sessions.count + 1
		}else if section == 2{
			return currencies.count + 1
		}else if section == 3{
			return visibilities.count + 1
		}else{
            return PackageService.pack.session.connectedPeers.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Ustawienia"
        }else if section == 1{
            return "Sesje"
		}else if section == 2{
			return "Waluty"
		}else if section == 3{
			return "Visibilities"
		}else{
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
		}else if indexPath.section == 2{
			if indexPath.row == 0{
				let cell = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! settingButtonCell
				cell.settingLabel?.text = "New Currency"
				cell.selectionStyle = .none
				cell.settingButton.setTitle("Create", for: .normal)
				cell.delegate = self
				
				return cell
			}else {
				let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell")
				let cellCurrency = currencies[indexPath.row - 1]
				cell?.textLabel?.text =	cellCurrency.name
				cell?.selectionStyle = .none
				cell?.accessoryType = .none
				
				if cellCurrency == Load.currentCurrency(){
					cell?.accessoryType = .checkmark
				}
				
				return cell!
			}
		}else if indexPath.section == 3{
			if indexPath.row == 0{
				let cell = tableView.dequeueReusableCell(withIdentifier: "settingButtonCell") as! settingButtonCell
				cell.settingLabel?.text = "New Visibility"
				cell.selectionStyle = .none
				cell.settingButton.setTitle("Create", for: .normal)
				cell.delegate = self
				
				return cell
			}else {
				let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell")
				let cellVisibility = visibilities[indexPath.row - 1]
				cell?.textLabel?.text =	cellVisibility.name
				
				if let color = NameGenerator.colors.first(where: {$0.0 == cellVisibility.name})?.1{
					cell?.textLabel?.textColor = color
				}
				
				cell?.selectionStyle = .none
				cell?.accessoryType = .none
				
				if cellVisibility.current{
					cell?.accessoryType = .checkmark
				}
			
				return cell!
			}
		}else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell")
            cell?.textLabel?.text = PackageService.pack.session.connectedPeers[indexPath.row].displayName
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
			
			PackageService.pack.send(syncAction)
			PackageService.pack.send(requestAction)
		}else if indexPath.section == 1 && indexPath.row > 0 && !sessions[indexPath.row - 1].current{
            let alert = UIAlertController(title: nil, message: "Do you want to change session", preferredStyle: .alert)
			
            let alertYes = UIAlertAction(title: "Tak", style: .destructive, handler: {(alert: UIAlertAction!) -> Void in
                self.switchedSession(indexPath: indexPath)
                
                let action = NSMutableDictionary()
                let actionType = NSNumber(value: ActionType.sessionSwitched.rawValue)
                
                action.setValue(actionType, forKey: "action")
                action.setValue(self.sessions[indexPath.row - 1].id, forKey: "sessionId")
                
                PackageService.pack.send(action)
            })
            
            let alertNo = UIAlertAction(title: "Nie", style: .cancel, handler: nil)
            
            alert.addAction(alertYes)
            alert.addAction(alertNo)
            
            present(alert, animated: true, completion: nil)
		}else if indexPath.section == 2{
			if indexPath.row == 0{
				createCurrency()
			}else{
				let session = Load.currentSession()
				
				let previousCurrencyIndex = currencies.index(of: session.currency!)! + 1
				
				session.currency = currencies[indexPath.row - 1]
				
				let rowsToReload = [indexPath, IndexPath(row: previousCurrencyIndex, section: indexPath.section)]
				
				tableView.reloadRows(at: rowsToReload, with: .fade)
			}
		}else if indexPath.section == 3{
			if indexPath.row != 0{
				var rowsToReload = [indexPath]

				let previousVisibilityIndex = visibilities.index(where: {$0.current})
				
				if let previousVisibilityIndex = previousVisibilityIndex{
					
					let previousRow = IndexPath(row: previousVisibilityIndex + 1, section: 3)
					
					if previousRow == indexPath{
						visibilities[previousVisibilityIndex].current = !visibilities[previousVisibilityIndex].current
					}else{
						visibilities[previousVisibilityIndex].current = false
						rowsToReload.append(previousRow)
					}
				}
				
				if rowsToReload.count == 2 || previousVisibilityIndex == nil{
					visibilities[indexPath.row - 1].current = true
				}
				
				CoreDataStack.saveContext()
				
				tableView.reloadRows(at: rowsToReload, with: .automatic)
			}
		}
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return (indexPath.section == 1 && indexPath.row != 0)
			|| (indexPath.section == 2 && indexPath.row != 0)
			|| (indexPath.section == 3 && indexPath.row != 0)
			||  indexPath.section == 4
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
					PackageService.pack.send(action)
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
				
				PackageService.pack.send(action)

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
			
		}else if indexPath.section == 2{
			let deleteCurrency = UITableViewRowAction(style: .destructive, title: "Remove", handler: { action, path in
				
				let currencyToDelete = self.currencies[indexPath.row - 1]
				
				self.currencies.remove(at: indexPath.row - 1)
				
				tableView.deleteRows(at: [indexPath], with: .automatic)
				
				let context = CoreDataStack.managedObjectContext
				context.delete(currencyToDelete)
				
				CoreDataStack.saveContext()
			})
			
			actions = [deleteCurrency]
		}else if indexPath.section == 3{
			let deleteVisibility = UITableViewRowAction(style: .destructive, title: "Remove", handler: { action, path in
				
				let visibilityToDelete = self.visibilities[indexPath.row - 1]
				
				self.visibilities.remove(at: indexPath.row - 1)
				
				tableView.deleteRows(at: [indexPath], with: .automatic)
				
				let context = CoreDataStack.managedObjectContext
				context.delete(visibilityToDelete)
				
				CoreDataStack.saveContext()
			})
			
			actions = [deleteVisibility]
		}else if indexPath.section == 4{
			actions = []
			let removePeer = UITableViewRowAction(style: .destructive, title: "Remove", handler: {action,path in
				
				let peer = PackageService.pack.session.connectedPeers[path.row]
				let action = NSMutableDictionary()
				let actionType: NSNumber = NSNumber(value: ActionType.disconnectPeer.rawValue)
				
				action.setValue(actionType, forKey: "action")
				action.setValue(peer.displayName, forKey: "peer")
				
				PackageService.pack.send(action)
				PackageService.pack.session.cancelConnectPeer(peer)
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
		guard let index = getCurrentCellIndexPath(sender, tableView: self.tableView) else { return } 
		
		if index.section == 1{
			createSeesion()
		}else if index.section == 2{
			createCurrency()
		}else if index.section == 3{
			createVisability()
		}
    }
	
	func createCurrency(){
		let currencyForm = NewCurrencyForm()
		
		currencyForm.modalPresentationStyle = .formSheet
		
		present(currencyForm, animated: true)

	}
	
	func createVisability(){
		let context = CoreDataStack.managedObjectContext
		let newVisability = NSEntityDescription.insertNewObject(forEntityName: String(describing: Visibility.self), into: context) as! Visibility
		
		let visibilityToReload = visibilities.index(where: {$0.current})
		
		
		newVisability.name = NameGenerator.createVisibilityData().0
		newVisability.current = true
		newVisability.id = String(describing: Date()) + newVisability.name!
		newVisability.session = Load.currentSession()
		
		visibilities.append(newVisability)
		
		tableView.beginUpdates()
		
		let indexToInsert = IndexPath(row: visibilities.count, section: 3)
		
		tableView.insertRows(at: [indexToInsert], with: .automatic)
		
		if let visibilityToReload = visibilityToReload{
			
			visibilities[visibilityToReload].current = false
			let indexToReload = IndexPath(row: visibilityToReload + 1, section: 3)
			
			tableView.reloadRows(at: [indexToReload], with: .automatic)
			
		}
		
		tableView.endUpdates()
		
		CoreDataStack.saveContext()
		
		let action = NSMutableDictionary()
		let actionType = NSNumber(value: ActionType.visibilityCreated.rawValue)
		
		action.setValue(actionType, forKey: "action")
		
		action.setValue(newVisability.name, forKey: "name")
		action.setValue(newVisability.id, forKey: "id")
		
		PackageService.pack.send(action)
	}
	
	func createSeesion(){
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
		
		let previousSessionIndex = sessions.index(where: {$0.current == true})
		
		let PLN = Load.currencies().first{$0.name == "PLN"}
		session.currency = PLN
		
        var devices = PackageService.pack.session.connectedPeers.map{$0.displayName}
        devices.append(UIDevice.current.name)
        
        session.devices = NSSet(array: devices)
		
        let index = IndexPath(row: tableView(self.tableView, numberOfRowsInSection: 1), section: 1)
        sessions.append(session)
        
        CoreDataStack.saveContext()

		tableView.beginUpdates()
		
		tableView.insertRows(at: [index], with: .automatic)
		
		if previousSessionIndex != nil{
			sessions[previousSessionIndex!].current = false
			
			let previousIndex = IndexPath(row: previousSessionIndex! + 1, section: 1)
			let currencySection = IndexSet(integer: 2)
			
			tableView.reloadRows(at: [previousIndex], with: .automatic)
			tableView.reloadSections(currencySection, with: .fade)
		}
		
		tableView.endUpdates()
		
        let action = NSMutableDictionary()
		let actionType = NSNumber(value: ActionType.sessionReceived.rawValue)
		
		action.setValue(actionType, forKey: "action")
		
		let sessionDictionary = packSessionForMessage(session)
		
		action.setValue(actionType, forKey: "action")
		action.setValue(sessionDictionary, forKey: "session")
		action.setValue(session.current, forKey: "setCurrent")
		
		PackageService.pack.send(action)
    }
}

extension Notification.Name{
    static let reload = Notification.Name("reload")
    static let addedSession = Notification.Name("addedSession")
    static let switchedSession = Notification.Name("switchedSession")
    static let sessionDeleted = Notification.Name("sessionDeleted")
	static let sessionReceived = Notification.Name("sessionReceived")
	static let currencyCreated = Notification.Name("currencyCreated")
	static let visibilityCreated = Notification.Name("visibilityCreated")
}
