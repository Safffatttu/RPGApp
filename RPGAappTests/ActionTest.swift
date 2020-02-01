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

}
