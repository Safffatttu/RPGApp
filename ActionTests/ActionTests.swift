//
//  ActionTests.swift
//  ActionTests
//
//  Created by Jakub Berkop on 01/02/2020.
//  Copyright © 2020 Jakub. All rights reserved.
//

import XCTest
import CoreData

@testable import RPGAapp

class NetworkActionTest: XCTestCase {
    
    let ad = ActionDelegate.ad
    let pack = PackageService.pack
    
    override func setUp() {
        let context = CoreDataStack.managedObjectContext
        Load.sessions().forEach({ context.delete($0) })
        Load.drawSettings().forEach({ context.delete($0) })
        Load.packages().forEach({ context.delete($0) })
        CoreDataStack.saveContext()
        super.setUp()
    }
    
    override class func tearDown() {
        let context = CoreDataStack.managedObjectContext
        Load.sessions().forEach({ context.delete($0) })
        Load.drawSettings().forEach({ context.delete($0) })
        Load.packages().forEach({ context.delete($0) })
        CoreDataStack.saveContext()
        super.tearDown()
    } 
    
    func testRandomActions() {
        let expect = XCTestExpectation(description: "expect")

        DispatchQueue.global().async {
            while PackageService.pack.session.connectedPeers.count == 0 {
                sleep(1)
            }

            expect.fulfill()
        }
         
        wait(for: [expect], timeout: 1000)
        
        
        let testEnded = XCTestExpectation()
        DispatchQueue.global().async {
            for n in 0...20 {
                print("test nr\(n)")
                self.executeAction()
                usleep(500000)
            }
            DispatchQueue.main.async {
                testEnded.fulfill()
            }
        }
        wait(for: [testEnded], timeout: 100000000)
    }
    
    func executeAction() {
        guard let randAction = ActionGenerator.actions.randomElement() else { return }

        let data = randAction()
        
        DispatchQueue.main.async {
            self.ad.receiveLocally(data)
        }
        
        guard let action = try? AnyAction(actionData: data) else {
            return
        }
        
        self.pack.send(action: action)
    }
    
}
