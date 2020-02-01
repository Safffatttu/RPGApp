//
//  LocalActionTest.swift
//  ActionTests
//
//  Created by Jakub Berkop on 01/02/2020.
//  Copyright © 2020 Jakub. All rights reserved.
//

import XCTest
import CoreData

@testable import RPGAapp

class LocalActionTest: XCTestCase {

    let ad = ActionDelegate.ad
    let pack = PackageService.pack
        
//    override class func tearDown() {
//        let context = CoreDataStack.managedObjectContext
//        Load.sessions().forEach({ context.delete($0) })
//        Load.drawSettings().forEach({ context.delete($0) })
//        CoreDataStack.saveContext()
//        super.tearDown()
//    }

    func LocalAction() {
        for n in 0...1000 {
            print("test nr\(n)")

            guard let randAction = ActionGenerator.actions.randomElement() else { continue }

            self.ad.receiveLocally(try! randAction())
        }
    }
}
