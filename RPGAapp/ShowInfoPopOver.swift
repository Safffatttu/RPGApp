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
    
    var item: Item? = nil
    @IBOutlet weak var descritionText: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        self.modalPresentationStyle = .popover
        
        self.preferredContentSize = CGSize(width: 300, height: 100)
        self.popoverPresentationController?.sourceRect = CGRect(x:0, y: 13,width: 0,height: 0)
        self.popoverPresentationController?.permittedArrowDirections = .right
        
        super.viewWillAppear(animated)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descritionText.text = item?.item_description
    }
    
}
