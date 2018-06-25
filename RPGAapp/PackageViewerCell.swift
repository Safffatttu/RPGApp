//
//  PackageViewerCell.swift
//  RPGAapp
//
//  Created by Jakub on 25.06.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import UIKit

class PackageViewerCell: UITableViewCell{
	
	@IBOutlet var itemTable: UITableView!
	
	@IBOutlet var nameLabel: UILabel!
	@IBOutlet var sendButton: UIButton!
	
	var package: Package!{
		didSet{
			items = package.items?.sortedArray(using: [.sortItemHandlerByName]) as! [ItemHandler]
			
			nameLabel.text = package.name
			
			sendButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize)
			sendButton.setTitle(String.fontAwesomeIcon(name: .send), for: .normal)
		}
	}
	
	var items: [ItemHandler]!
	
	override func awakeFromNib() {
		itemTable.dataSource = self
		
		NotificationCenter.default.addObserver(self, selector: #selector(reloadPackage), name: .addedItemToPackage, object: nil)
	}
	
	func reloadPackage(){
		items = package.items?.sortedArray(using: [.sortItemHandlerByName]) as! [ItemHandler]
		itemTable.reloadData()
	}
	
	@IBAction func sendItems(_ sender: UIButton) {
		
		let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sendPop")
		
		popController.modalPresentationStyle = UIModalPresentationStyle.popover
		
		popController.popoverPresentationController?.sourceView = sender
		
		(popController as! sendPopover).itemHandlers = items
		
		let topViewController = UIApplication.topViewController()
		
		topViewController?.present(popController, animated: true, completion: nil)
	}
}

extension PackageViewerCell: UITableViewDataSource{
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return items.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "PackageViewerItemCell")!
		
		let itemHandler = items[indexPath.row]
		cell.textLabel?.text = (itemHandler.item?.name)! + ": " + String(describing: itemHandler.count)
		
		return cell
	}
}
