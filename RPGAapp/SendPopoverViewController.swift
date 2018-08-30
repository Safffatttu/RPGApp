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
    
    var team: [Character] = Load.characters(usingVisibility: true)
	var from: Character? = nil{
		didSet{
			team = team.filter{$0 != from}
		}
	}
	
    override func viewWillAppear(_ animated: Bool) {
        
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
            cell.playerName.text = NSLocalizedString("No characters", comment: "")
            cell.sendButton.isHidden = true
        }
        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		sendActionTrigered(playerNum: indexPath.row)
	}
	
	func sendButtonPressed(_ sender: UIButton){
		guard let playerNum = getCurrentCellIndexPath(sender, tableView: self.tableView)?.row else { return }
		sendActionTrigered(playerNum: playerNum)
	}
	
	func sendActionTrigered(playerNum: Int){
		guard team.count > 0 && team.count > playerNum else { return }
		
		let recipient = team[playerNum]
		
		if let from = from{
			transferItem(from: from, to: recipient)
		}else{
			sendItem(to: recipient)
		}
	}
	
	func transferItem(from: Character, to: Character){
		
		guard let itemHandler = itemHandler else { return }
		guard let item = itemHandler.item else { return }
		
		addToEquipment(item: item, to: to)
		
		itemHandler.count -= 1
		
		var removed = false
		
		if itemHandler.count <= 0{
			from.removeFromEquipment(itemHandler)
			CoreDataStack.managedObjectContext.delete(itemHandler)
			removed = true
		}
		
		CoreDataStack.saveContext()
		
		NotificationCenter.default.post(name: .equipmentChanged, object: nil)
		
		let itemId = item.id
		
		let recipientAction = NSMutableDictionary()
		let recipientActionType = NSNumber(value: ActionType.itemCharacterAdded.rawValue)
		
		recipientAction.setValue(recipientActionType, forKey: "action")
		
		recipientAction.setValue(itemId, forKey: "itemId")
		recipientAction.setValue(1, forKey: "itemCount")
		recipientAction.setValue(to.id, forKey: "characterId")
		
		PackageService.pack.send(recipientAction)
		
		if removed{
			let removeAction = ItemCharacterDeleted(characterId: from.id!, itemId: itemId!)
			
			PackageService.pack.send(action: removeAction)
			
		}else{
			let fromAction = NSMutableDictionary()
			let fromActionType = NSNumber(value: ActionType.itemCharacterChanged.rawValue)
			fromAction.setValue(fromActionType, forKey: "action")
			
			fromAction.setValue(itemId, forKey: "itemId")
			fromAction.setValue(from.id, forKey: "characterId")
			
			fromAction.setValue(itemHandler.count, forKey: "itemCount")
			
			PackageService.pack.send(fromAction)
		}
		
		dismiss(animated: true)
	}
	
	func sendItem(to recipient: Character) {
        if let itemToAdd = item {
            addToEquipment(item: itemToAdd, to: recipient)
        }else if let handlerToAdd = itemHandler {
            addToEquipment(itemHandler: handlerToAdd, to: recipient)
        }else {
            for handler in itemHandlers{
                addToEquipment(itemHandler: handler, to: recipient)
            }
        }
        
        CoreDataStack.saveContext()
		
		NotificationCenter.default.post(name: .equipmentChanged, object: nil)
		
        dismiss(animated: true, completion: nil)
        
		let action: ItemCharacterAdded
		
        if let itemToSend = item {
            action = ItemCharacterAdded(itemId: itemToSend.id!)
			
        }else if let handlerToSend = itemHandler {
			action = ItemCharacterAdded(itemId: (handlerToSend.item?.id)!, itemCount: handlerToSend.count)
			
        }else {
            var itemsId: [String] = []
            var itemsCount: [Int64] = []

			for handler in itemHandlers{
                let itemId = handler.item?.id
                itemsId.append(itemId!)
                let itemCount = handler.count
                itemsCount.append(itemCount)
            }
			
			action = ItemCharacterAdded(itemsId: itemsId, itemsCount: itemsCount)
        }
		
        PackageService.pack.send(action: action)
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
