//
//  CatalogeFilterPopover.swift
//  RPGAapp
//
//  Created by Jakub on 19.11.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import UIKit

class catalogeFilterPopover: UITableViewController, filterCellDelegate {

    var filter: [String: Double?] = ["minRarity" : 0, "maxRarity" : 5, "minPrice" : 0, "maxPrice" : 100000000]
    var keys: [String] = []
    override func viewWillAppear(_ animated: Bool) {
        keys = filter.keys.flatMap({$0}).sorted()
        let height = 43 * keys.count - 1
        
        self.preferredContentSize = CGSize(width: 300, height: height)
        self.popoverPresentationController?.permittedArrowDirections = []
        self.tableView.isScrollEnabled = false
        super.viewWillAppear(true)
    }

    func valueChanged(_ sender: Any) {
        var index = getCurrentCellIndexPath(sender, tableView: self.tableView)
        filter[keys[(index?.row)!]] = Double((sender as! UISlider).value).rounded()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "catalogeFilterSlider", for: indexPath) as! catalogeFilterSlider
        cell.delegate = self
        
        cell.nameLabel.text = keys[indexPath.row]

        if (cell.nameLabel.text?.contains("max"))!{
            cell.slider.value = cell.slider.maximumValue
        }
        
        cell.slider.value = Float(filter[keys[indexPath.row]]!!)
        return cell
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

protocol filterCellDelegate {
    
    func valueChanged(_ sender: Any)
}
