//
//  CatalogeFilterCell.swift
//  RPGAapp
//
//  Created by Jakub on 10.09.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import UIKit

protocol CatalogeFilterCell {
	var filterItem: CatalogeFilterItem? { get set }
	func setup(using filterItem: CatalogeFilterItem) -> Void
}

class CatalogeFilterSlider: UITableViewCell, CatalogeFilterCell {
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var slider: UISlider!

	var filterItem: CatalogeFilterItem?
	
	override func awakeFromNib() {
		filterItem = nil
		super.awakeFromNib()
	}
	
	func setup(using filterItem: CatalogeFilterItem){
		guard self.filterItem == nil else { return }
		self.filterItem = filterItem
		
		self.nameLabel.text = "\(NSLocalizedString(filterItem.name, comment: "")) \(showPrice(filterItem.value))"
		
		self.slider.minimumValue = 0
		self.slider.maximumValue = 1
		
		self.slider.setValue(filterItem.valueForSlider, animated: true)
	}
	
	@IBAction func valueChanged(){
		filterItem?.setValueFromSlider(slider.value)
		self.nameLabel.text = "\(NSLocalizedString((filterItem?.name)!, comment: "")) \(showPrice((filterItem?.value)!))"
	}
}

class CatalogeFilterStepper: UITableViewCell, CatalogeFilterCell {
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var stepper: UIStepper!
	
	override func awakeFromNib() {
		NotificationCenter.default.addObserver(self, selector: #selector(reloadRange), name: .reloadFilterRange, object: nil)
	}
	
	var filterItem: CatalogeFilterItem?
	
	func setup(using filterItem: CatalogeFilterItem){
		self.filterItem = filterItem
		
		self.nameLabel.text = "\(NSLocalizedString(filterItem.name, comment: "")): \(rarityName[Int(filterItem.value) - 1])"
		
		let range = filterItem.range
		
		self.stepper.minimumValue = range.0
		self.stepper.maximumValue = range.1
		
		self.stepper.value = filterItem.value
	}
	
	@objc func reloadRange(){
		guard let range = filterItem?.range else { return }
		
		self.stepper.minimumValue = range.0
		self.stepper.maximumValue = range.1
	}
	
	@IBAction func valueChanged(){
		filterItem?.value = stepper.value
		self.nameLabel.text = "\(NSLocalizedString((filterItem?.name)!, comment: "")): \(rarityName[Int((filterItem?.value)!) - 1])"
	}
}

extension Notification.Name{
	static let reloadFilterRange = Notification.Name(rawValue: "reloadFilterRange")
}
