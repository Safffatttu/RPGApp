//
//  RandomItemCell.swift
//  RPGAapp
//
//  Created by Jakub on 06.09.2018.
//

import UIKit

class randomItemCell: UITableViewCell{
	
	@IBOutlet weak var nameLabel: UILabel!
	
	@IBOutlet weak var priceLabel: UILabel!
	
	@IBOutlet var packageButton: UIButton!
	
	@IBOutlet var redrawButton: UIButton!
	
	@IBOutlet var infoButton: UIButton!
	
	@IBOutlet var sendButton: UIButton!
	
	weak var cellDelegate: randomItemCellDelegate?
	
	var itemHandler: ItemHandler?{
		didSet{
			guard let itemHandler = self.itemHandler else { return }
			
			if itemHandler.count > 1 {
				nameLabel.text = (itemHandler.item?.name)! + ": " + String(describing: itemHandler.count)
			}
			else{
				nameLabel.text = (itemHandler.item?.name)!
			}
			
			var priceToShow = ""
			
			if let price = itemHandler.item?.price {
				priceToShow = showPrice(price)
			}
			
			priceLabel.text = priceToShow
		}
	}
	
	override func awakeFromNib() {		
		sendButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize, style: .regular)
		sendButton.setTitle(String.fontAwesomeIcon(name: .paperPlane), for: .normal)
		
		infoButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize, style: .regular)
		infoButton.setTitle(String.fontAwesomeIcon(name: .info), for: .normal)
		
		redrawButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize, style: .regular)
		redrawButton.setTitle(String.fontAwesomeIcon(name: .sync), for: .normal)
		
		packageButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize, style: .regular)
		packageButton.setTitle(String.fontAwesomeIcon(name: .cube), for: .normal)
		
		NotificationCenter.default.addObserver(self, selector: #selector(reloadPrice), name: .currencyChanged, object: nil)
	}
	
	@objc func reloadPrice(){
		var priceToShow = ""
		
		if let price = itemHandler?.item?.price {
			priceToShow = showPrice(price)
		}
		
		priceLabel.text = priceToShow
	}
	
	
	@IBAction func addToPackage(_ sender: UIButton) {
		cellDelegate?.addToPackage(sender)
	}
	
	@IBAction func redrawItem(_ sender: UIButton) {
		cellDelegate?.reDrawItem(sender)
	}
	
	@IBAction func showInfo(_ sender: UIButton) {
		cellDelegate?.showInfo(sender)
	}
	
	@IBAction func sendItem(_ sender: UIButton) {
		cellDelegate?.sendItem(sender)
	}
}

protocol randomItemCellDelegate: class{
	
	func addToPackage(_ sender: UIButton)
	
	func reDrawItem(_ sender: UIButton)
	
	func showInfo(_ sender: UIButton)
	
	func sendItem(_ sender: UIButton)
	
}
