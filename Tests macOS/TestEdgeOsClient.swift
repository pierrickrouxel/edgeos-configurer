//
//  TestEdgeOsClient.swift
//  Tests macOS
//
//  Created by Pierrick Rouxel on 01/07/2021.
//

import XCTest

class TestEdgeOsClient: XCTestCase {
    let edgeOsService = EdgeOsClient(host: "172.16.191.6", port: 22, username: "vyos", password: "vyos")

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        try edgeOsService.connect()
        let interfaces = try edgeOsService.showInterfaces()
        XCTAssertFalse(interfaces.count == 0)
    }

}
