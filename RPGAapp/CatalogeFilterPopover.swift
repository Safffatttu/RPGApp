//
//  CatalogeFilterPopover.swift
//  RPGAapp
//
//  Created by Jakub on 19.11.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import UIKit

class CatalogeFilterPopover: UITableViewController {

    var filter: [String: Double?] = [:]
    var keys: [String] = []
	
	var items: [Item]!{
		didSet{
			maxPrice = items.lazy.map{$0.price}.max()
			minPrice = items.lazy.map{$0.price}.min()
			maxRarity = Double(items.lazy.map{$0.rarity}.max()!)
			minRarity = Double(items.lazy.map{$0.rarity}.min()!)
		}
	}
	
	var maxPrice: Double!
	var minPrice: Double!
	var maxRarity: Double!
	var minRarity: Double!
	
    override func viewDidLoad() {
		items = Load.items()
		
		if filter.count == 0{
            filter["minPrice"] = minPrice
            filter["maxPrice"] = maxPrice
            filter["minRarity"] = minRarity
            filter["maxRarity"] = maxRarity
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        keys = filter.keys.flatMap({$0}).sorted()
        let height = 43 * keys.count - 1
        
        self.preferredContentSize = CGSize(width: 300, height: height)
        self.popoverPresentationController?.permittedArrowDirections = []
        self.tableView.isScrollEnabled = false
        
        super.viewWillAppear(animated)
    }

	@IBAction func valueChanged(_ sender: Any) {
		guard let indexPath = getCurrentCellIndexPath(sender as! UIControl, tableView: self.tableView) else { return }
		
		let cellKey = keys[indexPath.row]
		
		var val: Double! = 0
		
		if let slider = sender as? UISlider {
			val = Double(slider.value).rounded()
		}else if let stepper = sender as? UIStepper{
			val = stepper.value
		}
		
		filter[cellKey] = val
		
		let localizedCellName = NSLocalizedString(cellKey, comment: "")
		let labelText = localizedCellName + " " + String(format: "%g", filter[cellKey]!!)
		
		if cellKey.contains("Rarity"){
			(self.tableView.visibleCells[indexPath.row] as! catalogeFilterStepper).nameLabel.text = labelText
		}else{
			(self.tableView.visibleCells[indexPath.row] as! catalogeFilterSlider).nameLabel.text = labelText
		}
	}
	
	@IBAction func editingDidEnd(_ sender: Any) {
		NotificationCenter.default.post(name: .reloadCatalogeFilter, object: filter)
	}
        
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if keys[indexPath.row].contains("Rarity"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "catalogeFilterStepper", for: indexPath) as! catalogeFilterStepper
			
			let cellKey = keys[indexPath.row]
			let localizedCellName = NSLocalizedString(cellKey, comment: "")
			let labelText = localizedCellName + " " + String(format: "%g", filter[cellKey]!!)
            cell.nameLabel.text = labelText
			
            cell.stepper.maximumValue = maxRarity
            cell.stepper.minimumValue = minRarity
            
            cell.stepper.value = filter[cellKey]!!
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "catalogeFilterSlider", for: indexPath) as! catalogeFilterSlider
			
			cell.slider.isContinuous = true
			let cellKey = keys[indexPath.row]
			let localizedCellName = NSLocalizedString(cellKey, comment: "")
            cell.nameLabel.text = localizedCellName + " " + String(format: "%g", filter[cellKey]!!)
            
            if (keys[indexPath.row].contains("Price")){				
                cell.slider.maximumValue = Float(maxPrice)
                cell.slider.minimumValue = Float(minPrice)
            }
            cell.slider.setValue(Float(filter[keys[indexPath.row]]!!), animated: true)

            return cell
        }
    }
}

class catalogeFilterSlider: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var slider: UISlider!
}

class catalogeFilterStepper: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var stepper: UIStepper!
}
