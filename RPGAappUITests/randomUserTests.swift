//
//  randomUserTests.swift
//  RPGAapp
//
//  Created by Jakub on 27.12.2017.
//

import XCTest

class RandomUserTests: XCTestCase {
   
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        app.launchArguments = ["UITests"]
        app.launch()
        continueAfterFailure = false
    }

    override func tearDown() {
        super.tearDown()
    }

//    func testRecorded() {
//        
//        let app = XCUIApplication()
//        
//        let tablesQuery = app.tables
//        tablesQuery.staticTexts["Map"].swipeLeft()
//        tablesQuery.staticTexts["Draw Items"].tap()
//        app.otherElements.statusBars.children(matching: .other).element.children(matching: .other).element.tap()
//        app.navigationBars["MainMenu"].buttons["Main menu"].tap()
//        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Packages"]/*[[".cells.staticTexts[\"Packages\"]",".staticTexts[\"Packages\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        app.navigationBars["Main menu"].tap()
//        
//        app.navigationBars["Losowanie"].buttons["Main menu"].tap()
//        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Notes"]/*[[".cells.staticTexts[\"Notes\"]",".staticTexts[\"Notes\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Settings"]/*[[".cells.staticTexts[\"Settings\"]",".staticTexts[\"Settings\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        app.navigationBars["Settings"].buttons["Main menu"].tap()
//        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Cataloge"]/*[[".cells.staticTexts[\"Cataloge\"]",".staticTexts[\"Cataloge\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//    }
    
    
    func testRNG() {
        app.tables.staticTexts["Dice"].tap()
        
        app.tables.staticTexts["D4"].tap()
        app.tables.staticTexts["D6"].tap()
        app.tables.staticTexts["D10"].tap()
        app.tables.staticTexts["D12"].tap()
        app.tables.staticTexts["D20"].tap()
        app.tables.staticTexts["D100"].tap()
        app.tables.staticTexts["ADNormal"].tap()
        app.tables.staticTexts["AD2UP"].tap()
        app.tables.staticTexts["ADTo6"].tap()
                
        app.navigationBars["Losowanie"].buttons["Main menu"].tap()
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

extension XCUIElement {
    func forceTapElement() {
        if self.isHittable {
            self.tap()
        } else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0))
            coordinate.tap()
        }
    }
    func forceSwipeLeft() {
        while !visible() {
            swipeUp()
        }
        self.swipeLeft()
    }

    func visible() -> Bool {
        guard self.exists && !self.frame.isEmpty else { return false }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(self.frame)
    }
}
