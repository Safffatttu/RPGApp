//
//  ItemDetail.swift
//  characterGen1
//
//  Created by Jakub on 07.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit

class ItemDetailViewController: UIViewController {
    
    var currentItem: item?
    
    
    @IBOutlet var itemDescription: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemDescription.text = currentItem?.name
    }
    
}
