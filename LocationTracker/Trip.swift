//
//  Trip.swift
//  LocationTracker
//
//  Created by Ryan LaSante on 11/1/15.
//  Copyright © 2015 rlasante. All rights reserved.
//

import UIKit
import CoreLocation

class Trip: NSObject {

  private var points = [CLLocation]()

  func addLocation(location: CLLocation) {
    points.append(location)
  }

  func addLocations(locations: [CLLocation]) {
    points += locations
  }

  var locations : [CLLocation] {
    get {
      return points
    }
  }
}
