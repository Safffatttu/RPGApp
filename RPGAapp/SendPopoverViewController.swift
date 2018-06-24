//
//  catalogeSendPopoverViewController.swift
//  RPGAapp
//
//  Created by Jakub on 15.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit
import FontAwesome_swift
import CoreData

class sendPopover: UITableViewController, sendPopoverDelegate{
    
    var item: Item? = nil
    var itemHandler: ItemHandler? = nil
    var itemHandlers: [ItemHandler] = []
    
    var team: [Character] = []
        
    override func viewWillAppear(_ animated: Bool) {
        let session = Load.currentSession()
        team = session.characters?.sortedArray(using: [.sortCharacterById]) as! [Character]
        
        var height =  Int()
        var y = Int()
        if (team.count > 0){
            height = 45 * team.count - 1
            y = 13
        }
        else{
            height = 45
            y = 24
        }
        
        self.preferredContentSize = CGSize(width: 150, height: height)
        self.popoverPresentationController?.sourceRect = CGRect(x:0, y: y,width: 0,height: 0)
        self.popoverPresentationController?.permittedArrowDirections = .right
        
        super.viewWillAppear(animated)
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (team.count > 0){
            return team.count
        }
        else{
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sendPopoverCell") as! sendPopoverCell
        cell.cellDelegate = self
        if (team.count > 0){
            cell.playerName.text = team[indexPath.row].name
            cell.sendButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 20)
            cell.sendButton.setTitle(String.fontAwesomeIcon(name: .send), for: .normal)
        }
        else{
            cell.playerName.text = "Brak postaci"
            cell.sendButton.isHidden = true
        }
        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		sendItem(playerNum: indexPath.row)
	}
	
	func sendButtonPressed(_ sender: UIButton){
		if let playerNum = getCurrentCellIndexPath(sender, tableView: self.tableView)?.row{
			sendItem(playerNum: playerNum)
		}
	}
	
	
	func sendItem(playerNum: Int) {
		guard team.count >= playerNum - 1 else { return }
		
		let sendTo = team[playerNum]
		
        if let itemToAdd = item {
            addToEquipment(item: itemToAdd, to: sendTo)
        }else if let handlerToAdd = itemHandler {
            addToEquipment(itemHandler: handlerToAdd, to: sendTo)
        }else {
            for handler in itemHandlers{
                addToEquipment(itemHandler: handler, to: sendTo)
            }
        }
        
        CoreDataStack.saveContext()
        dismiss(animated: true, completion: nil)
        
        let action =  NSMutableDictionary()
        
        let actionType: NSNumber = NSNumber(value: ActionType.itemSend.rawValue)
        action.setValue(actionType, forKey: "action")
        
        if let itemToSend = item {
            action.setValue(itemToSend.id, forKey: "itemId")
            
        }else if let handlerToSend = itemHandler {
            action.setValue(handlerToSend.item?.id, forKey: "itemId")
            action.setValue(handlerToSend.count, forKey: "itemCount")
        }else {
            var itemsId: [String] = []
            var itemsCount: [Int64] = []
            for handler in itemHandlers{
                let itemId = handler.item?.id
                itemsId.append(itemId!)
                let itemCount = handler.count
                itemsCount.append(itemCount)
            }
            let itemsIdToSend = NSArray(array: itemsId)
            let itemsCountToSend = NSArray(array: itemsCount)
            
            action.setValue(itemsIdToSend, forKey: "itemsId")
            action.setValue(itemsCountToSend, forKey: "itemsCount")
        }

        action.setValue(sendTo.id, forKey: "characterId")
		
        PackageService.pack.send(action)
    }
}

class sendPopoverCell: UITableViewCell{
    
    weak var cellDelegate: sendPopoverDelegate?
    
    @IBAction func sendButtonAction(_ sender: UIButton){
        cellDelegate?.sendButtonPressed(sender)
    }
    
    @IBOutlet var sendButton: UIButton!
    
    @IBOutlet var playerName: UILabel!
    
}

protocol sendPopoverDelegate: class{
    
    func sendButtonPressed(_ sender: UIButton)
}
