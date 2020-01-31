//
//  TestLoadData.swift
//  RPGAappTests
//
//  Created by Jakub Berkop on 31/01/2020.
//  Copyright © 2020 Jakub. All rights reserved.
//

import XCTest
@testable import RPGAapp

class TestLoadData: XCTestCase {

    override func setUp() {

        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testLoad_items() {
        _ = Load.items()
    }

    func testLoad_item() {
        let testString = String(arc4random_uniform(100))
        _ = Load.item(with: testString)
    }

    func testLoad_subCategories() {
        _ = Load.subCategories()
    }

    func testLoad_categories() {
        _ = Load.categories()
    }

    func testLoad_sessions() {
        _ = Load.sessions()
    }

    func testLoad_session() {
        let testString = String(arc4random_uniform(100))
        _ = Load.session(with: testString)
    }

    func testLoad_currentExistingSession() {
        _ = Load.currentExistingSession()
    }

    func testLoad_currentSession() {
        _ = Load.currentSession()
    }

    func testLoad_packages() {
        let testString = String(arc4random_uniform(100))
        _ = Load.packages(with: testString)
    }

    func testLoad_drawSettings() {
        _ = Load.drawSettings()
    }

    func testLoad_characters() {
        _ = Load.characters()
    }

    func testLoad_character() {
        let testString = String(arc4random_uniform(100))
        _ = Load.character(with: testString)
    }

    func testLoad_currentMap() {
        guard let session = Load.sessions().randomElement() else { return }
        
        _ = Load.currentMap(session: session)
    }

    func testLoad_map() {
        let testString = String(arc4random_uniform(100))
        _ = Load.map(withId: testString)
    }

    func testLoad_mapEntity(withId id: String) {
        let testString = String(arc4random_uniform(100))
        _ = Load.mapEntity(withId: testString)
    }

    func testLoad_currencies() {
        _ = Load.currencies()
    }

    func testLoad_currentCurrency() {
        _ = Load.currentCurrency()
    }

    func testLoad_visibilities() {
        _ = Load.visibilities()
    }

    func testLoad_currentVisibility() {
        _ = Load.currentVisibility()
    }

    func testLoad_visibility() {
        let testString = String(arc4random_uniform(100))
        _ = Load.visibility(with: testString)
    }

    func testLoad_texture() {
        let testString = String(arc4random_uniform(100))
        _ = Load.texture(with: testString)
    }

    func testLoad_itemAtributes() {
        _ = Load.itemAtributes()
    }

    func testLoad_notes() {
        _ = Load.notes()
    }

    func testLoad_note() {
        let testString = String(arc4random_uniform(100))
        _ = Load.note(with: testString)
    }

}
