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
        XCUIDevice.shared.orientation = .landscapeRight
    }

    override func tearDown() {
        super.tearDown()
    }
   
    func testPackageViewer() {
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Packages"]/*[[".cells.staticTexts[\"Packages\"]",".staticTexts[\"Packages\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    }
        
    func testMap() {
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Map"]/*[[".cells.staticTexts[\"Map\"]",".staticTexts[\"Map\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["RPGAapp.MapView"].buttons["Add"].tap()
    }
        
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
