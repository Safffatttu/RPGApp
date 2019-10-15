//
//  DrawSettingCell.swift
//  RPGAapp
//
//  Created by Jakub on 24.06.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import Foundation
import UIKit

class DrawSettingCell: UITableViewCell {
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var subSettingTable: UITableView!
	
	var drawSetting: DrawSetting? = nil{
		didSet{
			subSettingTable.reloadData()
		}
	}
	
	override func prepareForReuse() {
		drawSetting = nil
		super.prepareForReuse()
	}
}

extension DrawSettingCell: UITableViewDataSource{
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let count = drawSetting?.subSettings?.count{
			return count
		}else{
			return 0
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "subSettingCell")
		let cellDrawSubSetting = drawSetting?.subSettings?.sortedArray(using: [.sortSubSettingByName])[indexPath.row] as! DrawSubSetting
		
		cell?.textLabel?.text = cellDrawSubSetting.name
		cell?.detailTextLabel?.text = String(cellDrawSubSetting.itemsToDraw)
		
		return cell!
	}
}
