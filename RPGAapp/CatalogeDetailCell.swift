//
//  CatalogeDetailswift
//  RPGAapp
//
//  Created by Jakub on 02.06.2018.
//

import Foundation
import UIKit


class CatalogeDetailCell: UITableViewCell {

	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var priceLabel: UILabel!

	@IBOutlet var packageButton: UIButton!
	@IBOutlet var editButton: UIButton!
	@IBOutlet var sendButton: UIButton!

	weak var cellDelegate: catalogeDetailCellDelegate?

	var item: Item? = nil {
		didSet {
			self.nameLabel.text = item?.name
			if let price = item?.price {
				self.priceLabel.text = showPrice(price)
			}
		}
	}

	override func awakeFromNib() {
		sendButton.setTitle("", for: .normal)
		sendButton.setImage(UIImage(systemName: "paperplane"), for: .normal)

		editButton.setTitle("", for: .normal)
		editButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)

		packageButton.setTitle("", for: .normal)
		packageButton.setImage(UIImage(systemName: "cube"), for: .normal)

		let longPress = UILongPressGestureRecognizer(target: self, action: #selector(sendAllItems(_:)))
		sendButton.addGestureRecognizer(longPress)

		NotificationCenter.default.addObserver(self, selector: #selector(changedCurrency), name: .currencyChanged, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(itemEdited(_:)), name: .editedItem, object: nil)
        super.awakeFromNib()
	}

	@objc
    func changedCurrency() {
		guard let price = self.item?.price else { return }
		self.priceLabel.text = showPrice(price)
	}

	@objc
    func itemEdited(_ notification: Notification) {
		guard let newItem = notification.object as? Item else { return }
		guard self.item == newItem else { return }

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

	@objc
    func sendAllItems(_ sender: UILongPressGestureRecognizer) {
		guard sender.state == .ended else { return }
		cellDelegate?.sendItemToAllButton(sendButton)
	}
}
