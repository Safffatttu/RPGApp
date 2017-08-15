//
//  catalogeSendPopoverViewController.swift
//  RPGAapp
//
//  Created by Jakub on 15.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import UIKit
import FontAwesome_swift

class sendPopover: UITableViewController, sendPopoverDelegate{
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return team.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sendPopoverCell") as! sendPopoverCell
        cell.playerName.text = team[indexPath.row].name
        
        cell.sendButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 20)
        cell.sendButton.setTitle(String.fontAwesomeIcon(name: .send), for: .normal)
        
        return cell
    }
    
    func getCurrentCellIndexPath(_ sender: UIButton) -> IndexPath? {
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        if let indexPath: IndexPath = tableView.indexPathForRow(at: buttonPosition) {
            return indexPath
        }
        return nil
    }
    
    func sendItem(_ sender: UIButton) {
        print(getCurrentCellIndexPath(sender))
    }
    
}

class sendPopoverCell: UITableViewCell{
    
    weak var cellDelegate: sendPopoverDelegate?
    
    @IBAction func sendButton(_ sender: UIButton){
        cellDelegate?.sendItem(sender)
    }
    
    @IBOutlet var sendButton: UIButton!
    
    
    @IBOutlet var playerName: UILabel!
    
}


protocol sendPopoverDelegate: class{
    
    func sendItem(_ sender: UIButton)
    
}
