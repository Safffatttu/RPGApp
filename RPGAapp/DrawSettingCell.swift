//
//  DrawSettingCell.swift
//  RPGAapp
//
//  Created by Jakub on 24.06.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import UIKit

class DrawSettingCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var nameLabel: UILabel!
	
	var drawSetting: DrawSetting? = nil
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (drawSetting?.subSettings?.count)!
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "subSettingCell")
		let cellDrawSubSetting = (drawSetting?.subSettings?.sortedArray(using: [NSSortDescriptor(key: #keyPath(DrawSubSetting.name), ascending: true)])[indexPath.row] as! DrawSubSetting)
		
		cell?.textLabel?.text = cellDrawSubSetting.name
		cell?.detailTextLabel?.text = String(cellDrawSubSetting.itemsToDraw)
		
		return cell!
	}
}
