//
//  DrawingTest.swift
//  RPGAappUITests
//
//  Created by Jakub Berkop on 31/01/2020.
//  Copyright © 2020 Jakub. All rights reserved.
//

import XCTest

class DrawingTest: XCTestCase {

    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launchArguments = ["UITests"]
        app.launch()
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .landscapeRight
    }

    func testDrawing() {
        let app = XCUIApplication()
        app.tables.staticTexts["Draw Items"].tap()
        app.tables["randomItemMenu"].cells.staticTexts["All items"].tap()
        app.buttons["Paczka"].tap()
        app.popovers.tables.buttons["plus.circle"].tap()
        app.otherElements["PopoverDismissRegion"].tap()
        
    }
}
