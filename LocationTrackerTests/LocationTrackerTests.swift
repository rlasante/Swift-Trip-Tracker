//
//  LocationTrackerTests.swift
//  LocationTrackerTests
//
//  Created by Ryan LaSante on 11/1/15.
//  Copyright © 2015 rlasante. All rights reserved.
//

import XCTest
@testable import LocationTracker
import CoreLocation

class LocationTrackerTests: XCTestCase {

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
    TripManager.sharedInstance.stopTracking()
    TripManager.sharedInstance.trips = []
  }

  func testTripManagerCreateTrip() {
    TripManager.sharedInstance.startTracking()
    XCTAssert(TripManager.sharedInstance.currentTrip != nil)
    TripManager.sharedInstance.stopTracking()
    XCTAssert(TripManager.sharedInstance.trips.count == 1)
    XCTAssert(TripManager.sharedInstance.currentTrip == nil)
  }

  func testTripManagerOnUpdate() {
    TripManager.sharedInstance.startTracking()
    XCTAssert(TripManager.sharedInstance.currentTrip != nil)
    TripManager.sharedInstance.locationManager(CLLocationManager(), didUpdateLocations: [CLLocation(coordinate: CLLocationCoordinate2D(latitude: 50, longitude: 0), altitude: 100, horizontalAccuracy: 50, verticalAccuracy: 50, course: 0, speed: 20, timestamp: NSDate())])
    let coordinate = TripManager.sharedInstance.currentTrip!.locations.first!.coordinate
    XCTAssert(coordinate.latitude == 50)
    XCTAssert(coordinate.longitude == 0)
    TripManager.sharedInstance.stopTracking()

  }

  func testCurrentSpeedUpdating() {
    TripManager.sharedInstance.startTracking()
  }
  //    func testPerformanceExample() {
  //        // This is an example of a performance test case.
  //        self.measureBlock {
  //            // Put the code you want to measure the time of here.
  //        }
  //    }
  
}
