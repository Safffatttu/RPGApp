//
//  SettingUiTest.swift
//  RPGAappUITests
//
//  Created by Jakub Berkop on 31/01/2020.
//  Copyright © 2020 Jakub. All rights reserved.
//

import XCTest

class SettingUiTest: XCTestCase {

    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launchArguments = ["UITests"]
        app.launch()
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .landscapeRight
    }
        
    func testSettings() {
        testSettings(numberOfTests: 10)
    }
    
    
    func testSettings(numberOfTests: Int = 100) {
        app.tables.staticTexts["Settings"].tap()
               
            for _ in 0...numberOfTests {
            
                let randomNum = Int(arc4random() % 4)
                let tablesQuery = app.tables
                
                switch randomNum {
                case 0:
                    tablesQuery.buttons["Add"].tap()
                case 1:
                    tablesQuery.staticTexts["Sync item database"].tap()
                case 2:
                    let staticTexts = tablesQuery.staticTexts
                    guard let staticText = staticTexts.allElementsBoundByIndex.randomElement() else { continue }
                    staticText.forceTapElement()
                case 3:
                    let createButton = tablesQuery.cells.containing(.staticText, identifier: "New visibility").buttons["Create"]
                    createButton.tap()
                    tablesQuery.staticTexts["Visibilities"].swipeLeft()
                case 4:
                    tablesQuery.staticTexts.allElementsBoundByIndex.randomElement()?.swipeDown()
                case 5:
                    let plnStaticText = tablesQuery.staticTexts["PLN"]
                    plnStaticText.swipeLeft()
                    app.tables.containing(.other, identifier: "CURRENCIES").element.swipeLeft()
                    plnStaticText.swipeDown()
                    tablesQuery.cells.containing(.staticText, identifier: "New Currency").buttons["Create"].tap()
                    tablesQuery.cells.containing(.staticText, identifier: "Name").children(matching: .textField).element.tap()
                    tablesQuery.staticTexts["Add new SubCurrency"].tap()
                    tablesQuery.children(matching: .cell).element(boundBy: 2).children(matching: .textField).element.tap()
                    tablesQuery.staticTexts["Remove SubCurrency"].tap()
                    tablesQuery.staticTexts["Create new currency"].tap()
                    tablesQuery.staticTexts["Dismiss changes"].tap()
                default:
                    continue
                }
                if app.alerts.scrollViews.otherElements.count > 0 {
                    if arc4random() % 2 == 0 {
                        app.alerts.scrollViews.otherElements.buttons["Yes"].tap()
                    } else {
                        app.alerts.scrollViews.otherElements.buttons["No"].tap()
                    }
                }
            }
        app.navigationBars["Settings"].buttons["Main menu"].tap()
        clickCell(query: app.cells)
    }
    
    func clickCell(query: XCUIElementQuery) {
        let cellsCount = query.count
        guard cellsCount > 0 else { return }
        let cell = query.allElementsBoundByIndex[
            Int(arc4random()) % cellsCount
        ]
        cell.forceTapElement()
    }

}
