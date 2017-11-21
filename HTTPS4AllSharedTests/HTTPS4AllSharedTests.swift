//
//  HTTPS4AllSharedTests.swift
//  HTTPS4AllSharedTests
//
//  Created by Bouke van der Bijl on 21/11/2017.
//  Copyright © 2017 Bouke van der Bijl. All rights reserved.
//

import XCTest
@testable import HTTPS4AllShared

class HTTPS4AllSharedTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testReadHosts() {
		let exampleHosts = Bundle(for: HTTPS4AllSharedTests.self).url(forResource: "example-hosts", withExtension: "txt")!
		let hosts = try! readHosts(exampleHosts)
		XCTAssertEqual([
			"bouk.co",
			"https4all.org",
			"eff.org",
			], hosts)
    }
}
