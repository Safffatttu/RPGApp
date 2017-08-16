//
//  ShowInfoPopOver.swift
//  RPGAapp
//
//  Created by Jakub on 16.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit

class showItemInfoPopover: UIViewController {
    
    var itemToShow: Int = 0
    
    @IBOutlet weak var descritionText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(itemToShow)
        descritionText.text = listOfItems.items[itemToShow].description
    }
    
}
