//
//  CenteredLabelCell.swift
//  RPGAapp
//
//  Created by Jakub on 20.05.2018.
//

import Foundation
import UIKit
import Former

final class CenteredLabelCell: UITableViewCell, LabelFormableRow{

	@IBOutlet weak var centerTextLabel: UILabel!
	
	func formTextLabel() -> UILabel? {
		return centerTextLabel
	}
	
	func formSubTextLabel() -> UILabel? {
		return nil
	}
	
	func updateWithRowFormer(_ rowFormer: RowFormer) {
	}
	
}
