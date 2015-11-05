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
import ReactiveCocoa

class LocationTrackerTests: XCTestCase {

  func createDummyLocation() -> CLLocation {
    return CLLocation(coordinate: CLLocationCoordinate2D(latitude: 50, longitude: 0), altitude: 100, horizontalAccuracy: 10, verticalAccuracy: 10, course: 0, speed: 10, timestamp: NSDate())
  }

  func createDummyLocation(speed: Double) -> CLLocation {
    return CLLocation(coordinate: CLLocationCoordinate2D(latitude: 50, longitude: 0), altitude: 100, horizontalAccuracy: 10, verticalAccuracy: 10, course: 0, speed: speed, timestamp: NSDate())
  }

  func createDummy2Location() -> CLLocation {
    return CLLocation(coordinate: CLLocationCoordinate2D(latitude: -50, longitude: 0), altitude: 100, horizontalAccuracy: 10, verticalAccuracy: 10, course: 0, speed: 10, timestamp: NSDate())
  }

  override func setUp() {
    super.setUp()
    TripManager.sharedInstance.trips = []
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
    TripManager.sharedInstance.stopTracking()
    TripManager.sharedInstance.trips = []
  }

  func testTripManagerEmptyTrip() {
    TripManager.sharedInstance.startTracking()
    XCTAssert(TripManager.sharedInstance.currentTrip != nil)
    TripManager.sharedInstance.stopTracking()
    XCTAssert(TripManager.sharedInstance.trips.count == 0)
    XCTAssert(TripManager.sharedInstance.currentTrip == nil)
  }

  func testTripManagerOnUpdate() {
    TripManager.sharedInstance.startTracking()
    XCTAssert(TripManager.sharedInstance.currentTrip != nil)
    TripManager.sharedInstance.locationManager(CLLocationManager(), didUpdateLocations: [createDummyLocation()])
    let coordinate = TripManager.sharedInstance.currentTrip!.rawPoints.first!.coordinate
    XCTAssert(coordinate.latitude == 50)
    XCTAssert(coordinate.longitude == 0)
    TripManager.sharedInstance.stopTracking()

  }

  func testCurrentSpeedUpdating() {
    let updateSpeed = 100.0
    let expectation = expectationWithDescription("Speed Updated")
    TripManager.sharedInstance.currentSpeedSignal().take(1).observeNext { (speed) -> () in
      XCTAssert(updateSpeed == speed, "Original Value: \(updateSpeed) NewValue: \(speed)")
      expectation.fulfill()
    }
    TripManager.sharedInstance.startTracking()
    TripManager.sharedInstance.locationManager(CLLocationManager(), didUpdateLocations: [createDummyLocation(updateSpeed)])
    TripManager.sharedInstance.stopTracking()

    waitForExpectationsWithTimeout(1, handler: nil)
  }

  func testImpossibleLocationsOmitted() {
    TripManager.sharedInstance.startTracking()
    TripManager.sharedInstance.locationManager(CLLocationManager(), didUpdateLocations: [createDummyLocation()])
    TripManager.sharedInstance.locationManager(CLLocationManager(), didUpdateLocations: [createDummy2Location()])
    TripManager.sharedInstance.stopTracking()
    XCTAssert(TripManager.sharedInstance.trips.count == 0)
  }

}
