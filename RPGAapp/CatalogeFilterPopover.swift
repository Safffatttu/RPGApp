//
//  CatalogeFilterPopover.swift
//  RPGAapp
//
//  Created by Jakub on 19.11.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import UIKit

class catalogeFilterPopover: UITableViewController, filterCellDelegate {

    var filter: [String: Double?] = [:]
    var keys: [String] = []
    
    override func viewDidLoad() {
        if filter.count == 0{
            let items = loadItems()
            
            let maxPrice: Double = {
                return (items.max { (item1, item2) -> Bool in item1.price < item2.price}?.price)!
            }()
            
            let minPrice: Double = {
                return (items.min { (item1, item2) -> Bool in item1.price < item2.price}?.price)!
            }()
            
            let maxRarity: Double = {
                return Double((items.max { (item1, item2) -> Bool in item1.rarity < item2.rarity}?.rarity)!)
            }()
            
            let minRarity: Double = {
                return Double((items.min { (item1, item2) -> Bool in item1.rarity < item2.rarity}?.rarity)!)
            }()
            
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

    func valueChanged(_ sender: Any) {
        var index = getCurrentCellIndexPath(sender, tableView: self.tableView)
        var val: Double! = 0
        if let slider = sender as? UISlider {
            val = Double(slider.value).rounded()
        }else if let stepper = sender as? UIStepper{
            val = stepper.value
        }
        filter[keys[(index?.row)!]] = val
        
        let label = keys[(index?.row)!] + " " + String(format: "%g", filter[keys[(index?.row)!]]!!)
        
        if keys[(index?.row)!].contains("Rarity"){
            (self.tableView.visibleCells[(index?.row)!] as! catalogeFilterStepper).nameLabel.text = label
        }else{
            (self.tableView.visibleCells[(index?.row)!] as! catalogeFilterSlider).nameLabel.text = label
        }
        
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
            
            cell.delegate = self as filterCellDelegate
            
            cell.nameLabel.text = keys[indexPath.row] + " " + String(format: "%g", filter[keys[indexPath.row]]!!)
            
            let items = loadItems()
            
            let maxRarity: Double = {
                return Double((items.max { (item1, item2) -> Bool in item1.rarity < item2.rarity}?.rarity)!)
            }()
            
            let minRarity: Double = {
                return Double((items.min { (item1, item2) -> Bool in item1.rarity < item2.rarity}?.rarity)!)
            }()
            
            cell.stepper.maximumValue = maxRarity
            cell.stepper.minimumValue = minRarity
            
            cell.stepper.value = filter[keys[indexPath.row]]!!
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "catalogeFilterSlider", for: indexPath) as! catalogeFilterSlider
        
            cell.delegate = self as filterCellDelegate
            
            cell.nameLabel.text = keys[indexPath.row] + " " + String(format: "%g", filter[keys[indexPath.row]]!!)
            
            if (keys[indexPath.row].contains("Price")){
                let items = loadItems()
                
                let maxPrice: Double = {
                    return (items.max { (item1, item2) -> Bool in item1.price < item2.price}?.price)!
                }()
                
                
                let minPrice: Double = {
                    return (items.min { (item1, item2) -> Bool in item1.price < item2.price}?.price)!
                }()
                
                cell.slider.maximumValue = Float(maxPrice)
                cell.slider.minimumValue = Float(minPrice)
                print(cell.slider.maximumValue)
            }
            cell.slider.setValue(Float(filter[keys[indexPath.row]]!!), animated: true)

            return cell
        }
    }
}

class catalogeFilterSlider: UITableViewCell {
    
    var delegate: filterCellDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var slider: UISlider!
    
    @IBAction func sliderMoved(_ sender: Any) {
        delegate?.valueChanged(sender)
    }
}

class catalogeFilterStepper: UITableViewCell {
    
    var delegate: filterCellDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var stepper: UIStepper!
    
    @IBAction func valueChanged(_ sender: Any) {
        delegate?.valueChanged(sender)
    }
}

protocol filterCellDelegate {
    
    func valueChanged(_ sender: Any)
}
