//
//  TestEdgeOsClient.swift
//  Tests macOS
//
//  Created by Pierrick Rouxel on 01/07/2021.
//

import XCTest

class TestEdgeOsClient: XCTestCase {
    let edgeOsClient = EdgeOsClientMock(host: "192.168.1.1", port: 22, username: "vyos", password: "vyos")

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testShowInterfaces() throws {
        try edgeOsClient.connect()
        let interfaces = try edgeOsClient.showInterfaces()
        
        XCTAssertFalse(interfaces.count == 0)
        
        let eth0 = interfaces.first { interface in
            interface.interface == "eth0"
        }
        
        XCTAssert(eth0?.ipAddress == "192.168.1.1/24")
    }
    
    class EdgeOsClientMock: EdgeOsClient {
        var connected = false
        
        override func connect() throws {
            connected = true
        }
        
        override func execute(_ command: String) throws -> String {
            guard connected else {
                throw EdgeOsClientError.notConnected
            }
            
            switch command {
            case "show interfaces":
                return """
                    Codes: S - State, L - Link, u - Up, D - Down, A - Admin Down
                    Interface        IP Address                        S/L  Description
                    ---------        ----------                        ---  -----------
                    eth0             192.168.1.1/24                    u/u
                    lo               127.0.0.1/8                       u/u
                                     ::1/128
                    """
            default:
                return ""
            }
        }
    }
}
