//
//  catalogeSendPopoverViewController.swift
//  RPGAapp
//
//  Created by Jakub on 15.08.2017.
//

import Foundation
import UIKit
import FontAwesome_swift
import CoreData

class SendPopover: UITableViewController, sendPopoverDelegate {
    
    var item: Item?
    var itemHandler: ItemHandler?
    var itemHandlers: [ItemHandler] = []
    
    var team: [Character] = Load.characters(usingVisibility: true)
	var from: Character? = nil {
		didSet {
			team = team.filter {$0 != from}
		}
	}

    override func viewWillAppear(_ animated: Bool) {
        
        var height = Int()
        var y = Int()
        if team.count > 0 {
            height = 45 * team.count - 1
            y = 13
        } else {
            height = 45
            y = 24
        }
        
        self.preferredContentSize = CGSize(width: 150, height: height)
        self.popoverPresentationController?.sourceRect = CGRect(x: 0, y: y, width: 0, height: 0)
        self.popoverPresentationController?.permittedArrowDirections = .right
        
        super.viewWillAppear(animated)
	
		NotificationCenter.default.addObserver(self, selector: #selector(reloadTeam), name: .reloadTeam, object: nil)
	}

	@objc
    func reloadTeam() {
		team = Load.characters(usingVisibility: true)
		self.viewWillAppear(true)
	}
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if team.count > 0 {
            return team.count
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SendPopoverCell") as! SendPopoverCell
        cell.cellDelegate = self
        if team.count > 0 {
            cell.playerName.text = team[indexPath.row].name
            cell.sendButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 20, style: .regular)
            cell.sendButton.setTitle(String.fontAwesomeIcon(name: .paperPlane), for: .normal)
        } else {
            cell.playerName.text = NSLocalizedString("No characters", comment: "")
            cell.sendButton.isHidden = true
        }
        return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		sendActionTrigered(playerNum: indexPath.row)
	}

	func sendButtonPressed(_ sender: UIButton) {
		guard let playerNum = getCurrentCellIndexPath(sender, tableView: self.tableView)?.row else { return }
		sendActionTrigered(playerNum: playerNum)
	}

	func sendActionTrigered(playerNum: Int) {
		guard team.count > 0 && team.count > playerNum else { return }
	
		let recipient = team[playerNum]
	
		if let from = from {
			transferItem(from: from, to: recipient)
		} else {
			sendItem(to: recipient)
		}
	}

	func transferItem(from: Character, to: Character) {
	
		guard let itemHandler = itemHandler else { return }
		guard let item = itemHandler.item else { return }
	
		addToEquipment(item: item, to: to)
	
		itemHandler.count -= 1
	
		var removed = false
	
		if itemHandler.count <= 0 {
			from.removeFromEquipment(itemHandler)
			CoreDataStack.managedObjectContext.delete(itemHandler)
			removed = true
		}
	
		CoreDataStack.saveContext()
	
		NotificationCenter.default.post(name: .equipmentChanged, object: nil)
	
		let itemId = item.id
	
		let recipientAction = ItemCharacterAdded(characterId: to.id!, itemId: itemId!)
	
		PackageService.pack.send(action: recipientAction)
	
		if removed {
			let removeAction = ItemCharacterDeleted(characterId: from.id!, itemId: itemId!)

			PackageService.pack.send(action: removeAction)

		} else {
			let fromAction = ItemCharacterChanged(characterId: from.id!, itemId: itemId!, itemCount: itemHandler.count)

			PackageService.pack.send(action: fromAction)
		}
	
		dismiss(animated: true)
	}

	func sendItem(to recipient: Character) {
        if let itemToAdd = item {
            addToEquipment(item: itemToAdd, to: recipient)
        } else if let handlerToAdd = itemHandler {
            addToEquipment(itemHandler: handlerToAdd, to: recipient)
        } else {
            for handler in itemHandlers {
                addToEquipment(itemHandler: handler, to: recipient)
            }
        }
        
        CoreDataStack.saveContext()
	
		NotificationCenter.default.post(name: .equipmentChanged, object: nil)
	
        dismiss(animated: true, completion: nil)
        
		let action: ItemCharacterAdded
	
        if let itemToSend = item {
			action = ItemCharacterAdded(characterId: recipient.id!, itemId: itemToSend.id!)

        } else if let handlerToSend = itemHandler {
			action = ItemCharacterAdded(characterId: recipient.id!, itemId: (handlerToSend.item?.id)!, itemCount: handlerToSend.count)

        } else {
            var itemsId: [String] = []
            var itemsCount: [Int64] = []

			for handler in itemHandlers {
                let itemId = handler.item?.id
                itemsId.append(itemId!)
                let itemCount = handler.count
                itemsCount.append(itemCount)
            }

			action = ItemCharacterAdded(characterId: recipient.id!, itemsId: itemsId, itemsCount: itemsCount)
        }
	
        PackageService.pack.send(action: action)
    }
}

class SendPopoverCell: UITableViewCell {
    
    weak var cellDelegate: sendPopoverDelegate?
    
    @IBAction func sendButtonAction(_ sender: UIButton) {
        cellDelegate?.sendButtonPressed(sender)
    }
    
    @IBOutlet var sendButton: UIButton!
    
    @IBOutlet var playerName: UILabel!
    
}

protocol sendPopoverDelegate: class {
    
    func sendButtonPressed(_ sender: UIButton)
}
