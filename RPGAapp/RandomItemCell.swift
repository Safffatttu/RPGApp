//
//  RandomItemCell.swift
//  RPGAapp
//
//  Created by Jakub on 06.09.2018.
//

import UIKit

class RandomItemCell: UITableViewCell {

	@IBOutlet weak var nameLabel: UILabel!

	@IBOutlet weak var priceLabel: UILabel!

	@IBOutlet var packageButton: UIButton!

	@IBOutlet var redrawButton: UIButton!

	@IBOutlet var infoButton: UIButton!

	@IBOutlet var sendButton: UIButton!

	weak var cellDelegate: randomItemCellDelegate?

	var itemHandler: ItemHandler? {
		didSet {
			guard let itemHandler = self.itemHandler else { return }

			if itemHandler.count > 1 {
				nameLabel.text = (itemHandler.item?.name)! + ": " + String(describing: itemHandler.count)
			} else {
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
		sendButton.setTitle("", for: .normal)
        sendButton.setImage(UIImage(systemName: "paperplane"), for: .normal)
	
		infoButton.setTitle("", for: .normal)
		infoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
	
		redrawButton.setTitle("", for: .normal)
		redrawButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
	
		packageButton.setTitle("", for: .normal)
		packageButton.setImage(UIImage(systemName: "cube"), for: .normal)
	
		NotificationCenter.default.addObserver(self, selector: #selector(reloadPrice), name: .currencyChanged, object: nil)
        super.awakeFromNib()
	}

	@objc
    func reloadPrice() {
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

protocol randomItemCellDelegate: class {

	func addToPackage(_ sender: UIButton)

	func reDrawItem(_ sender: UIButton)

	func showInfo(_ sender: UIButton)

	func sendItem(_ sender: UIButton)

}
