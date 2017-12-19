//
//  RandomNumberGenerator.swift
//  RPGAapp
//
//  Created by Jakub on 07.12.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import UIKit

class RandomNumberGenerator: UITableViewController {

    let draw = [4,6,10,12,20,100]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return draw.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = "k" + String(draw[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let number = myRand(draw[indexPath.row])
        let message = "Wylosowano " + String(number)
        showPopover(with: message)
        
        let action = NSMutableDictionary()
        let at = NSNumber(value: ActionType.generatedRandomNumber.rawValue)
 
        action.setValue(at, forKey: "action")
        action.setValue(number, forKey: "number")
        
        let packageService = (UIApplication.shared.delegate as! AppDelegate).pack
        packageService.send(action)
        
        return
        
    }
}
