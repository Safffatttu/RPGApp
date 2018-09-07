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
	
	var allowFloatingPoint: Bool = true
	
	func updateWithRowFormer(_ rowFormer: RowFormer) {}

	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {		
		let separators = CharacterSet.init(charactersIn: ".,")
		let digits = CharacterSet.decimalDigits
		
		var allowedCharacters = digits
		
		if allowFloatingPoint{
			allowedCharacters = allowedCharacters.union(separators)
		}
		
		let containsOnlyAllowedCharacters = string.rangeOfCharacter(from: allowedCharacters.inverted) == nil
		
		let numberOfSeparators = textField.text?.characters.filter{$0 == "," || $0 == "."}.count
		let isSeparator = string.rangeOfCharacter(from: separators) != nil
		let allowedNumberOfSeparators = numberOfSeparators! == 1
		let allowedSeparators = !(allowedNumberOfSeparators && isSeparator)
		
		return containsOnlyAllowedCharacters && allowedSeparators
	}
	
}
