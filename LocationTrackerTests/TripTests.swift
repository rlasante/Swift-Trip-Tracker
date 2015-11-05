//
//  TripTests.swift
//  LocationTracker
//
//  Created by Ryan LaSante on 11/1/15.
//  Copyright © 2015 rlasante. All rights reserved.
//

import XCTest
import CoreLocation

@testable import LocationTracker

class TripTests: XCTestCase {

  func testAddingLocation() {
    let trip = Trip()
    let lat = 51.5033630
    let long = -0.1276250
    trip.addLocation(CLLocation(latitude: lat, longitude: long))
    XCTAssert(trip.rawPoints.count == 1)
    XCTAssert(trip.rawPoints[0].coordinate.latitude == lat)
    XCTAssert(trip.rawPoints[0].coordinate.longitude == long)
  }

  func testAddMultipleLocations() {
    let lat = 51.5033630
    let long = -0.1276250
    let points = [CLLocation(latitude: lat, longitude: long), CLLocation(latitude: lat + 1, longitude: long + 1)]
    let trip = Trip()
    trip.addLocations(points)
    XCTAssert(trip.rawPoints.count == 2)
    for (index, location) in trip.rawPoints.enumerate() {
      let point = points[index]
      XCTAssert(location.coordinate.latitude == point.coordinate.latitude)
      XCTAssert(location.coordinate.longitude == point.coordinate.longitude)
    }
  }

}
