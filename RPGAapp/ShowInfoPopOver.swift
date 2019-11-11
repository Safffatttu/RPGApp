//
//  ShowInfoPopOver.swift
//  RPGAapp
//
//  Created by Jakub on 16.08.2017.
//

import Foundation
import UIKit

class ShowItemInfoPopover: UIViewController {

    var item: Item?
    @IBOutlet weak var descritionText: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        self.modalPresentationStyle = .popover

        let characters = Double((item?.item_description?.count)!)

        let height = round(characters / 20) * 20 + 20
        let width = round(characters / 50) * 40 + 300

        self.preferredContentSize = CGSize(width: width, height: height)
        self.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 13, width: 0, height: 0)
        self.popoverPresentationController?.permittedArrowDirections = .right

        descritionText.text = item?.item_description
        super.viewWillAppear(animated)
    }
}
