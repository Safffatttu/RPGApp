//
//  ProfileFieldCell.swift
//  Former-Demo
//
//  Created by Ryo Aoyama on 10/31/15.
//

import UIKit
import Former

final class ProfileFieldCell: UITableViewCell, TextFieldFormableRow {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!


    func formTextField() -> UITextField {
        return textField
    }

    func formTitleLabel() -> UILabel? {
        return titleLabel
    }

    func updateWithRowFormer(_ rowFormer: RowFormer) {}
}
