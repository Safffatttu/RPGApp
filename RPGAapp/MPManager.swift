//
//  MPManager.swift
//  RPGAapp
//
//  Created by Jakub on 13.08.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class PackageService: NSObject{
    
    let serviceType = "RPGapp"
	let info = ["other info": "info"]
    let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    
    let serviceAdvertiser: MCNearbyServiceAdvertiser
    let serviceBrowser: MCNearbyServiceBrowser
    
    var delegate: PackageServiceDelegate?
	
	static var pack = PackageService()
    
    override init(){
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: info, serviceType: serviceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        
        super.init()
        print("initialized")
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
		
		self.delegate = ActionDelegate.ad
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
        print("deinit")
    }
    
    
    lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        return session
    }()
    
    func send(_ action: NSMutableDictionary){
        NSLog("%@", "send")
            if session.connectedPeers.count > 0{
            do{
                let data = NSKeyedArchiver.archivedData(withRootObject: action)
                try self.session.send(data, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error{
                NSLog("Error: \(error)")
            }
        }
    }
	
	func send(_ action: NSMutableDictionary,to peer: MCPeerID){
		NSLog("%@", "sendTo")
		if session.connectedPeers.count > 0{
			do{
				let data = NSKeyedArchiver.archivedData(withRootObject: action)
				try self.session.send(data, toPeers: [peer], with: .reliable)
			}
			catch let error{
				NSLog("Error: \(error)")
			}
		}
	}
}

extension PackageService: MCNearbyServiceAdvertiserDelegate{
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.session)
    }
}

extension PackageService: MCNearbyServiceBrowserDelegate{

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 30)
        self.delegate?.found(peerID)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        self.delegate?.lost(peerID)
        NSLog("%@", "lostPeer: \(peerID)")
    }
}

extension PackageService: MCSessionDelegate{
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state)")
        self.delegate?.connectedDevicesChanged(manager: self, connectedDevices: session.connectedPeers.map{$0.displayName})
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        let action = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSMutableDictionary
        action.setValue(peerID.displayName, forKey: "sender")
		DispatchQueue.main.async {
			self.delegate?.received(action,from: peerID)
		}
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
}

protocol PackageServiceDelegate {
    
    func connectedDevicesChanged(manager : PackageService, connectedDevices: [String])
    func lost(_ peer: MCPeerID)
    func found(_ peer: MCPeerID)
    func received(_ action: NSMutableDictionary,from sender: MCPeerID)
}

enum ActionType: Int {
    case applicationWillTerminate = 0
    case applicationDidEnterBackground
    case itemSend
    case packageCreated
    case packageDeleted
    case packageSend
    case itemAddedToPackge
    case characterCreated
    case disconnectPeer
    case itemDeletedFromCharacter
    case sessionCreated
    case sessionSwitched
    case sessionDeleted
    case generatedRandomNumber
	case addedAbilityToCharacter
	case valueOfAblilityChanged
	case removeAbility
	case removeCharacter
	case itemHandlerCountChanged
	case sessionReceived
	case itemsRequest
	case itemsRequestResponse
	case mapEntityMoved
	case itemDataSend
	case requestedItemList
	case recievedItemList
	case syncItemLists
	case sendImage
	case currencyCreated
	case visibilityCreated
	case characterVisibilityChanged
	case itemDeletedFromPackage
}

extension Notification.Name{
    static let connectedDevicesChanged = Notification.Name("connectedDevicesChanged")
}
