//
//  RPGAappUITests.swift
//  RPGAappUITests
//
//  Created by Jakub on 26.12.2017.
//  Copyright © 2017 Jakub. All rights reserved.
//

import XCTest

class RPGAappUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        
        let app = XCUIApplication()
        app.launchEnvironment = ["UITEST_DISABLE_ANIMATIONS" : "YES"]
        app.launchArguments = ["UITests"]
        app.launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    func testReDrawFirstCell() {
        
        let tablesQuery = XCUIApplication().tables
        tablesQuery.staticTexts["Items"].tap()
        tablesQuery.staticTexts["Losowanie Przedmiotu"].tap()
        tablesQuery.staticTexts["Domowe"].tap()
        
        let app = XCUIApplication()
        let tableView = app.tables.containing(.table, identifier: "selectedTable")
        
        for i in 0...1000{
            print("reDraw numer: " + String(i))
            tableView.cells.element(boundBy: 0).buttons[""].tap()
        }
    }

    func testReDrawRandomCell() {
        
        let tablesQuery = XCUIApplication().tables
        tablesQuery.staticTexts["Items"].tap()
        tablesQuery.staticTexts["Losowanie Przedmiotu"].tap()

        let app = XCUIApplication()
        
        let tableView = app.tables.containing(.table, identifier: "selectedTable")
        
        for _ in 0...10{
            selectRandomDrawOption(app: app)
                for i in 0...10{
                    print("reDraw numer: " + String(i))
                    let index = UInt(arc4random_uniform(UInt32(tableView.cells.count)))
                    tableView.cells.element(boundBy: index).buttons[""].tap()
                }
        }
    }
    
    func selectRandomDrawOption(app: XCUIApplication){
        let tableView = app.tables.containing(.table, identifier: "randomItemMenu")
        let index = UInt(arc4random_uniform(UInt32(tableView.cells.count)))
        tableView.cells.element(boundBy: index).tap()
        
    }
    
}
