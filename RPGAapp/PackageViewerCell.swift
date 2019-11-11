//
//  PackageViewerCell.swift
//  RPGAapp
//
//  Created by Jakub on 25.06.2018.
//

import Foundation
import UIKit
import Dwifft

class PackageViewerCell: UITableViewCell {
	
	@IBOutlet var itemTable: UITableView!
	
	@IBOutlet var nameLabel: UILabel!
	@IBOutlet var sendButton: UIButton!
	
	var package: Package? {
		didSet {
			guard let it = package?.items?.sortedArray(using: [.sortItemHandlerByName]) as? [ItemHandler] else {
				items = []
				itemTable.reloadData()
				return
			}
			items = it
			
			nameLabel.text = package?.name
			
            sendButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize, style: .regular)
            sendButton.setTitle(String.fontAwesomeIcon(name: .paperPlane), for: .normal)
		}
	}
	
	struct Val: Equatable {
		var name: String
		var count: Int64
		
		static func ==(lhs: PackageViewerCell.Val, rhs: PackageViewerCell.Val) -> Bool {
			return lhs.count == rhs.count && lhs.name == rhs.name
		}
	}
	
	var diffTable : [Val] = []
	
	func setDiffTable() {
		diffTable = []
		for han in items {
			guard let name = han.item?.id else { continue }
			let newVal = Val(name: name, count: han.count)
			diffTable.append(newVal)
		}
	}
	
	var items: [ItemHandler] = [] {
		didSet {
			setDiffTable()
			diffCalculator?.rows = diffTable
		}
	}
	
	var diffCalculator: SingleSectionTableViewDiffCalculator<Val>?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		itemTable.dataSource = self
		
		NotificationCenter.default.addObserver(self, selector: #selector(reloadPackage), name: .addedItemToPackage, object: nil)
		
		let removeItem = UILongPressGestureRecognizer(target: self, action: #selector(removeItemLongPress(_:)))
		removeItem.delegate = self
		self.itemTable.addGestureRecognizer(removeItem)
		
		diffCalculator = SingleSectionTableViewDiffCalculator(tableView: itemTable)
	}
	
	override func prepareForReuse() {
		package = nil		
		super.prepareForReuse()
	}
	
	
	@objc func reloadPackage() {
		guard let items = package?.items?.sortedArray(using: [.sortItemHandlerByName]) as? [ItemHandler] else { return }
		self.items = items
	}
	
	@IBAction func sendItems(_ sender: UIButton) {
		
		let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sendPop")
		
		popController.modalPresentationStyle = UIModalPresentationStyle.popover
		
		popController.popoverPresentationController?.sourceView = sender
		
		(popController as! SendPopover).itemHandlers = items
		
		let topViewController = UIApplication.topViewController()
		
		topViewController?.present(popController, animated: true, completion: nil)
	}
	
	var removeItemCancelled: Bool = false
	var lastCellIndex: IndexPath? = nil
	
	@objc func removeItemLongPress(_ sender: UILongPressGestureRecognizer) {
		let touchPoint = sender.location(in: self.contentView)
		
		guard let indexPath = itemTable.indexPathForRow(at: touchPoint) else {
			guard let index = lastCellIndex else { return }
			guard let cell = itemTable.cellForRow(at: index) else { return }
			
			UIView.animate(withDuration: 0.2, animations: {
				cell.backgroundColor = .white
			})
			
			return
		}
		
		lastCellIndex = indexPath
		
		guard let cell = itemTable.cellForRow(at: indexPath) else { return }
		
		switch sender.state {
		case .changed:
			removeItemCancelled = true
			break
			
		case .began:
			removeItemCancelled = false
			
			UIView.animate(withDuration: sender.minimumPressDuration, animations: {
				cell.backgroundColor = .red
			})
			break
			
		case .ended:
			guard !removeItemCancelled else {
				UIView.animate(withDuration: 0.2, animations: {
					cell.backgroundColor = .white
				})
				
				break
			}
			let context = CoreDataStack.managedObjectContext
			
			let item = items[indexPath.row]
			let itemId = item.item?.id
			
			package?.removeFromItems(item)
			
			context.delete(item)
			CoreDataStack.saveContext()
			
			reloadPackage()
			
			cell.backgroundColor = .white
			
			let action = ItemPackageDeleted(package: package!, itemId: itemId!)
			PackageService.pack.send(action: action)
			
			removeItemCancelled	= false
			
		case .cancelled:
			removeItemCancelled = true
			
		default:
			UIView.animate(withDuration: 0.2, animations: {
				cell.backgroundColor = .white
			})
		}
	}
}

extension PackageViewerCell: UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return items.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "PackageViewerItemCell")!
		
		let itemHandler = items[indexPath.row]
		
		if let name = itemHandler.item?.name {
			cell.textLabel?.text = "\(name) \(itemHandler.count)"
		}else {
			cell.textLabel?.text = ""
		}

		cell.selectionStyle = .none
		
		return cell
	}
}
