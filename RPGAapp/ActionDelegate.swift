//
//  ActionDelegate.swift
//  RPGAapp
//
//  Created by Jakub on 12.11.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import Popover
import MultipeerConnectivity

class ActionDelegate: NSObject, PackageServiceDelegate{
    
    func recieved(_ action: NSMutableDictionary, manager: PackageService) {
        let actionType = ActionType(rawValue: action.value(forKey: "action") as! Int)
        let sender = action.value(forKey: "sender") as? String
        
        if actionType == ActionType.applicationDidEnterBackground{
            let message = sender! + " wyszedł z aplikacji"
            showPopover(with: message)
        }
    }
    
    func lost(_ peer: MCPeerID) {
        let message = "Utracono połączenie z " + peer.displayName
        showPopover(with: message)
    }
    

    func connectedDevicesChanged(manager: PackageService, connectedDevices: [String]) {
        return
    }
    
    
    func showPopover(with message: String){
        DispatchQueue.main.async {
            let point = CGPoint(x: 15, y: 20)
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
            let frame = CGRect(x: view.frame.minX, y: view.frame.minY, width: view.frame.maxX, height: view.frame.maxY)
            let label = UILabel(frame: frame)
            label.text = message
            label.textAlignment = .center
            label.center = view.center
            view.addSubview(label)
            let popover = Popover()
            popover.arrowSize = .zero
            popover.show(view, point: point)
        }
    }
    
}