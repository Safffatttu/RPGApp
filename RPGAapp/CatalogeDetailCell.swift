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
	@IBOutlet var infoButton: UIButton!
	@IBOutlet var sendButton: UIButton!
	
	weak var cellDelegate: catalogeDetailCellDelegate?
	
	var item: Item? = nil{
		didSet{
			self.nameLabel.text = item?.name
			self.priceLabel.text = String(describing: item?.price) + "PLN"
		}
	}
	
	override func awakeFromNib() {
		sendButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize)
		sendButton.setTitle(String.fontAwesomeIcon(name: .send), for: .normal)
		
		infoButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize)
		infoButton.setTitle(String.fontAwesomeIcon(name: .info), for: .normal)
		
		editButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize)
		editButton.setTitle(String.fontAwesomeIcon(name: .edit), for: .normal)
		
		packageButton.titleLabel?.font = UIFont.fontAwesome(ofSize: iconSize)
		packageButton.setTitle(String.fontAwesomeIcon(name: .cube), for: .normal)
	}
	
	
	@IBAction func addToPackageButton(_ sender: UIButton) {
		cellDelegate?.addToPackageButton(sender)
	}
	
	@IBAction func editItemButton(_ sender: UIButton) {
		cellDelegate?.editItemButton(sender)
	}
	
	@IBAction func showInfoButton(_ sender: UIButton) {
		cellDelegate?.showInfoButton(sender)
	}
	
	@IBAction func sendItemButton(_ sender: UIButton) {
		cellDelegate?.sendItemButton(sender)
	}
	
}