//
//  LocationTrackerUITests.swift
//  LocationTrackerUITests
//
//  Created by Ryan LaSante on 11/1/15.
//  Copyright © 2015 rlasante. All rights reserved.
//

import XCTest

class LocationTrackerUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
      let startButton = XCUIApplication().buttons.elementMatchingType(.Button, identifier: "start")
      let stopButton = XCUIApplication().buttons.elementMatchingType(.Button, identifier: "stop")
      let delayStopExpectation = expectationWithDescription("Delay for pressing stop button")

      startButton.tap()
      dispatch_after(3, dispatch_get_main_queue()) { () -> Void in
        stopButton.tap()
        delayStopExpectation.fulfill()
      }
      waitForExpectationsWithTimeout(10, handler: nil)
    }
    
}
