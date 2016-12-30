//
//  TheWeatherUITests.swift
//  TheWeatherUITests
//
//  Created by Matthew Carroll on 12/2/16.
//  Copyright © 2016 Third Cup lc. All rights reserved.
//

import XCTest


class TheWeatherUITests: UITestCase {
    
    func testHeader() {
        let formatter = DateFormatter(dateFormat: "MMMM d", timeZone: nil)
        formatter.dateFormat = "MMMM d"
        let dateString = formatter.string(from: Date())
        let monthDay = app.descendantMatchingIdentifier(id: "header.monthDay")
        XCTAssert(monthDay.label == dateString, "month day label is incorrect \(monthDay.label)")
        assertMinMaxTemps()
    }
    
    func assertMinMaxTemps() {
        refreshExpectation()
        let hiTemp = app.descendantMatchingIdentifier(id: "header.hiTemp")
        let baseURL = "http://api.openweathermap.org/data/2.5"
        let currentConditionsURL = URL(string: baseURL + "/weather?q=Atlanta,ga&units=imperial&appid=ab298dd3d8f93043e672f412b02fac88")!
        let currentConditions = Resource<JSONDictionary>(url: currentConditionsURL, parseJSON: { json in
            json as? JSONDictionary
        })
        HTTPClient().load(resource: currentConditions) { json in
            mainQueue.add {
                guard let main = json?["main"] as? JSONDictionary, let temp = main["temp_max"] as? Double else {
                    return XCTFail("failed to fetch max temp")
                }
                let tempString = Int(temp).description
                var tempLabel = hiTemp.label
                tempLabel.dropLast()
                XCTAssertEqual(tempLabel, tempString, "max temp label is incorrect \(tempLabel)")
            }
            self.expectation.fulfill()
        }
        waitForExpectationsWithDefaultTimeout()
    }
    
    func test5DayCells() {
        let baseURL = "http://api.openweathermap.org/data/2.5"
        let fiveDayURL = URL(string: baseURL + "/forecast/daily?q=Atlanta,ga&units=imperial&cnt=5&appid=ab298dd3d8f93043e672f412b02fac88")!
        let fiveDay = Resource<JSONDictionary>(url: fiveDayURL, parseJSON: { json in
            json as? JSONDictionary
        })
        refreshExpectation()
        HTTPClient().load(resource: fiveDay, completion: assertCellsShowCorrectData)
        waitForExpectationsWithDefaultTimeout()
    }
    
    func assertCellsShowCorrectData(json: JSONDictionary?) {
        mainQueue.add {
            guard let days = json?["list"] as? [JSONDictionary] else {
                return XCTFail("failed to fetch forecasts")
            }
            for i in 1..<5 {
                let d = days[i]
                guard let temp = d["temp"] as? JSONDictionary, let hiTemp = temp["max"] as? Double, let lowTemp = temp["min"] as? Double else {
                    return XCTFail("failed to fetch temps")
                }
                let cell = self.app.tables.cells.element(boundBy: UInt(i - 1))
                self.assertCellLabel(cell: cell, labelID: "hiTemp", value: hiTemp)
                self.assertCellLabel(cell: cell, labelID: "lowTemp", value: lowTemp)
            }
            self.expectation.fulfill()
        }
    }
    
    func assertCellLabel(cell: XCUIElement, labelID: String, value: Double) {
        let temp = cell.descendantMatchingIdentifier(id: labelID)
        var tempLabel = temp.label
        tempLabel.dropLast()
        let tempInt = Int(value).description
        XCTAssertEqual(tempLabel, tempInt, "temp label is incorrect \(tempLabel)")
    }
}
