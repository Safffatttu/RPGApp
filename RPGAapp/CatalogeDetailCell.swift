//
//  CatalogeDetailswift
//  RPGAapp
//
//  Created by Jakub on 02.06.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import UIKit


class CatalogeDetailCell: UITableViewCell{
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var priceLabel: UILabel!
	
	@IBOutlet var packageButton: UIButton!
	@IBOutlet var editButton: UIButton!
	@IBOutlet var sendButton: UIButton!
	
	weak var cellDelegate: catalogeDetailCellDelegate?
	
	var item: Item? = nil{
		didSet{
			self.nameLabel.text = item?.name
			if let price = item?.price{
				self.priceLabel.text = showPrice(price)
			}
		}
	}
	
	override func awakeFromNib() {
		sendButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize)
		sendButton.setTitle(String.fontAwesomeIcon(name: .send), for: .normal)
		
		editButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize)
		editButton.setTitle(String.fontAwesomeIcon(name: .edit), for: .normal)
		
		packageButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize)
		packageButton.setTitle(String.fontAwesomeIcon(name: .cube), for: .normal)
		
		let longPress = UILongPressGestureRecognizer(target: self, action: #selector(sendAllItems(_:)))
		sendButton.addGestureRecognizer(longPress)
		
		NotificationCenter.default.addObserver(self, selector: #selector(changedCurrency), name: .currencyChanged, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(itemEdited(_:)), name: .editedItem, object: nil)
	}
	
	func changedCurrency(){
		guard let price = self.item?.price else { return }
		self.priceLabel.text = showPrice(price)
	}
	
	func itemEdited(_ notification: Notification){
		guard let newItem = notification.object as? Item else { return }
		guard self.item == newItem else { return	}
		
		self.item = newItem
	}
	
	@IBAction func addToPackageButton(_ sender: UIButton) {
		cellDelegate?.addToPackageButton(sender)
	}
	
	@IBAction func editItemButton(_ sender: UIButton) {
		cellDelegate?.editItemButton(sender)
	}
	
	@IBAction func sendItemButton(_ sender: UIButton) {
		cellDelegate?.sendItemButton(sender)
	}
	
	func sendAllItems(_ sender: UILongPressGestureRecognizer){
		guard sender.state == .ended else { return }
		cellDelegate?.sendItemToAllButton(sendButton)
	}
}
