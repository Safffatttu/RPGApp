//
//  ActionTest.swift
//  RPGAapp
//
//  Created by Jakub on 15.05.2018.
//

import Foundation
import XCTest
import UIKit
import CoreData
import MultipeerConnectivity

@testable import RPGAapp

class ActionTest: XCTestCase {

	let ad = ActionDelegate.ad
	let pack = PackageService.pack
	override func setUp() {
		super.setUp()

	}
    
    override class func tearDown() {
        let context = CoreDataStack.managedObjectContext
        Load.sessions().forEach({ context.delete($0) })
        Load.drawSettings().forEach({ context.delete($0) })
        CoreDataStack.saveContext()
        super.tearDown()
    }

//	func testRandomActions() {
//
//		let expect = XCTestExpectation(description: "expect")
//
//		DispatchQueue.global().async {
//			while PackageService.pack.session.connectedPeers.count == 0 {
//				sleep(1)
//			}
//
//			expect.fulfill()
//		}
//		 
//		wait(for: [expect], timeout: 1000)
//
//		DispatchQueue.main.async {
//			for n in 0...1000 {
//				print("test nr\(n)")
//
//				guard let randAction = self.actions.randomElement() else { continue }
//
//                let data = randAction()
//				self.ad.receiveLocally(data)
//                
//                guard let action = try? AnyAction(actionData: data) else {
////                    print(data)
//                    continue
//                }
//                
//                self.pack.send(action: action)
//
//				sleep(1)
//			}
//		}
//	}
//
//	func testLocalAction() {
//		for n in 0...1000 {
//			print("test nr\(n)")
//
//			guard let randAction = self.actions.randomElement() else { continue }
//
//            self.ad.receiveLocally(try! randAction())
//		}
//	}
}
