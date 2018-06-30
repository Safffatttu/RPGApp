//
//  NumbericalFieldCell.swift
//  RPGAapp
//
//  Created by Jakub on 30.06.2018.
//  Copyright © 2018 Jakub. All rights reserved.
//

import UIKit
import Former

final class NumberFieldCell: UITableViewCell, TextFieldFormableRow, UITextFieldDelegate{
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var textField: UITextField!
	
	func formTextField() -> UITextField {
		textField.delegate = self
		return textField
	}
	
	func formTitleLabel() -> UILabel? {
		return titleLabel
	}
	
	func updateWithRowFormer(_ rowFormer: RowFormer) {}

	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let stringWithoutSeparators = string.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: ".", with: "")
		
		let numberSeparators = CharacterSet.init(charactersIn: ".,")
		let digits = CharacterSet.decimalDigits
		let allowedCharacters = digits.union(numberSeparators)
		
		let containsOnlyAllowedCharacters = stringWithoutSeparators.rangeOfCharacter(from: allowedCharacters.inverted) == nil
		
		return containsOnlyAllowedCharacters
	}
	
}
