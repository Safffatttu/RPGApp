//
//  SearchTest.swift
//  RPGAappTests
//
//  Created by Jakub Berkop on 09/10/2019.
//

import XCTest
@testable import RPGAapp

class SearchTest: XCTestCase {

    var dataSource: CatalogeDataSource!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.dataSource = CatalogeDataSource()
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testWordSearch() {
        guard let text: String = Load.items().randomElement()?.name else { return }
        NotificationCenter.default.post(name: .searchCataloge, object: text)

        XCTAssert(dataSource.items.count > 0)
    }

    func testSortModel() {
        let sortTypesCount: UInt32 = UInt32(dataSource.model.sortModel.count)
        let randomSortType: Int = Int(arc4random_uniform(sortTypesCount))
        dataSource.model.sortModel.select(index: randomSortType)
        NotificationCenter.default.post(name: .catalogeModelChanged, object: nil)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        guard let text: String = Load.items().randomElement()?.name else { return }
        self.measure {
            NotificationCenter.default.post(name: .searchCataloge, object: text)
            XCTAssert(dataSource.items.count > 0)
        }
    }

}
