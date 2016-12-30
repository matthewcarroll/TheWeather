//
//  UITestCase.swift
//
//  Created by Matthew Carroll on 1/25/16.
//  Copyright © 2016 Third Cup lc. All rights reserved.
//

import XCTest

class UITestCase: XCTestCase {

    var expectation = XCTestExpectation()
    let sixtySecondDefaultTimeout = TimeInterval(60)
    var app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func refreshExpectation() {
        expectation = expectation(description: description)
    }
    
    func waitForExpectationsWithDefaultTimeout() {
        waitForExpectations(timeout: sixtySecondDefaultTimeout) { error in
            XCTAssertNil(error, "Timeout error \(error)")
        }
    }
    
}
