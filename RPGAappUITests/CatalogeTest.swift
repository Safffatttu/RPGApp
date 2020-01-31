//
//  CatalogeTest.swift
//  RPGAappUITests
//
//  Created by Jakub Berkop on 31/01/2020.
//  Copyright © 2020 Jakub. All rights reserved.
//

import XCTest

class CatalogeTest: XCTestCase {

    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launchArguments = ["UITests"]
        app.launch()
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .landscapeRight
    }

    func testCataloge() {
        app.tables.staticTexts["Cataloge"].tap()
        
        let organizeButton = app.navigationBars["MainMenu"].buttons["Organize"]
        organizeButton.tap()
        app.tables.cells
            .containing(.staticText, identifier: "Minimal rarity: Junk")
            .buttons["Increment"].tap()
        
        
        app.navigationBars["RPGAapp.CatalogeDetail"].buttons["Create item"].tap()
        let nameTextField = app.tables.cells.containing(.staticText, identifier: "Name").children(matching: .textField).element
        nameTextField.tap()
        nameTextField.typeText(String(arc4random()))
    }

}
