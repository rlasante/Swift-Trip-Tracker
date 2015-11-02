//
//  LocationManager.swift
//  LocationTracker
//
//  Created by Ryan LaSante on 11/1/15.
//  Copyright © 2015 rlasante. All rights reserved.
//

import UIKit
import CoreLocation
import ReactiveCocoa


class TripManager: NSObject, CLLocationManagerDelegate {
  static let sharedInstance = TripManager()
  private let (speedSignal, speedObserver) = Signal<CLLocationSpeed, NoError>.pipe()
  private let (tripSignal, tripObserver) = Signal<Trip, NoError>.pipe()

  private lazy var locationManager: CLLocationManager = {
    let manager = CLLocationManager()
    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyBest
    manager.requestWhenInUseAuthorization()
    return manager
  }()

  var trips = [Trip]()
  var currentTrip: Trip?

  private override init() {
    super.init()
  }

  func startTracking() {
    guard CLLocationManager.locationServicesEnabled() else {
      return
    }
    currentTrip = Trip()
    locationManager.startUpdatingLocation()
  }

  func stopTracking() {
    guard CLLocationManager.locationServicesEnabled() else {
      return
    }
    locationManager.stopUpdatingLocation()
    if let trip = currentTrip {
      trips.append(trip)
    }
    currentTrip = nil
    speedObserver.sendNext(0)
  }

  func currentSpeedSignal() -> Signal<CLLocationSpeed, NoError> {
    return speedSignal
  }

  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    speedObserver.sendNext(locations.last!.speed)
    if let trip = currentTrip {
      trip.addLocations(locations)
    }
  }
}
