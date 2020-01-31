//
//  TestTeamViewUI.swift
//  RPGAappUITests
//
//  Created by Jakub Berkop on 31/01/2020.
//  Copyright © 2020 Jakub. All rights reserved.
//

import XCTest

class TestTeamViewUI: XCTestCase {

    var app: XCUIApplication!
        
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launchArguments = ["UITests"]
        app.launch()
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .landscapeRight
    }
    
    func testTeamView() {
        app.tables.staticTexts["Team View"].tap()
        app.navigationBars["RPGAapp.TeamView"].buttons["Add"].tap()
        let nameTextField = app.tables.cells.containing(.staticText, identifier: "Name").children(matching: .textField).element
        nameTextField.tap()
        nameTextField.typeText(String(arc4random()))
        
        app.tables.staticTexts["Create new character"].tap()
        
        let collectionViewsQuery2 = app.collectionViews
        let steppersQuery = collectionViewsQuery2/*@START_MENU_TOKEN@*/.steppers/*[[".cells.steppers",".steppers"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        steppersQuery.buttons["Increment"].tap()
        steppersQuery.buttons["Decrement"].tap()
        collectionViewsQuery2.cells.otherElements.containing(.staticText, identifier: "Abilities").children(matching: .table).element(boundBy: 0).tap()
        
        let collectionViewsQuery = collectionViewsQuery2
        collectionViewsQuery.tables.cells.children(matching: .textField).element.tap()
        collectionViewsQuery.buttons["square.and.pencil"].tap()
        app.tables.staticTexts["Dismiss changes"].tap()
        collectionViewsQuery.buttons["trash"].tap()
        app.alerts["Are you sure you want to remove character?"].scrollViews.otherElements.buttons["Yes"].tap()
    }
}
