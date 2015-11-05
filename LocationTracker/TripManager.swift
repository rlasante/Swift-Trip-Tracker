//
//  LocationManager.swift
//  LocationTracker
//
//  Created by Ryan LaSante on 11/1/15.
//  Copyright © 2015 rlasante. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import ReactiveCocoa


class TripManager: NSObject, CLLocationManagerDelegate {
  static let sharedInstance = TripManager()
  private let (speedSignal, speedObserver) = Signal<CLLocationSpeed, NoError>.pipe()
  private let (tripSignal, tripObserver) = Signal<Trip, NoError>.pipe()

  var trips = [Trip]()
  var currentTrip: Trip?

  private lazy var locationManager: CLLocationManager = {
    let manager = CLLocationManager()
    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyBest
    manager.requestWhenInUseAuthorization()
    return manager
  }()

  private lazy var managedObjectContext: NSManagedObjectContext = {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    return appDelegate.managedObjectContext
  }()

  private func saveContext() {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    appDelegate.saveContext()
  }

  private override init() {
    super.init()
    loadSavedTrips()
    tripSignal.observeNext {[weak self] (trip) -> () in
      self?.trips.append(trip)
      self?.saveTrip(trip)
    }
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
    if let trip = currentTrip where !trip.locations.isEmpty {
      tripObserver.sendNext(trip)
    }
    currentTrip = nil
    speedObserver.sendNext(0)
  }

  func currentSpeedSignal() -> Signal<CLLocationSpeed, NoError> {
    // Returns the signal that sends the current speed in meters per second
    return speedSignal
  }

  func completedTripSignal() -> Signal<Trip, NoError> {
    return tripSignal
  }

  private func loadSavedTrips() {
    let fetchRequest = NSFetchRequest(entityName: "Trip")
    do {
      let results = try self.managedObjectContext.executeFetchRequest(fetchRequest)
      let tripObjects = results as! [NSManagedObject]
      for tripObject in tripObjects {
        trips.append(Trip(object: tripObject))
      }
    } catch let error as NSError {
      print("Unable to fetch \(error). \(error.userInfo)")
    }
  }
  
  private func saveTrip(trip: Trip) {
    let tripEntity = NSEntityDescription.entityForName("Trip", inManagedObjectContext: self.managedObjectContext)
    let tripObject = NSManagedObject(entity: tripEntity!, insertIntoManagedObjectContext: self.managedObjectContext)
    let locations = getLocationEntities(trip)
    if locations.count > 0 {
      tripObject.setValue(Set(locations), forKey: "locations")
    }
    self.saveContext()
  }

  private func getLocationEntities(trip: Trip) -> [NSManagedObject] {
    var managedLocations = [NSManagedObject]()
    for location in trip.locations {
      let locationEntity = NSEntityDescription.entityForName("Location", inManagedObjectContext: self.managedObjectContext)
      let locationObject = NSManagedObject(entity: locationEntity!,
        insertIntoManagedObjectContext: self.managedObjectContext)

      locationObject.setValue(NSNumber(double: location.altitude), forKey: "altitude")
      locationObject.setValue(NSNumber(double: location.course), forKey: "course")
      locationObject.setValue(NSNumber(double: location.coordinate.latitude), forKey: "lat")
      locationObject.setValue(NSNumber(double: location.coordinate.longitude), forKey: "long")
      locationObject.setValue(NSNumber(double: location.horizontalAccuracy), forKey: "horizontalAccuracy")
      locationObject.setValue(NSNumber(double: location.verticalAccuracy), forKey: "verticalAccuracy")
      locationObject.setValue(NSNumber(double: location.speed), forKey: "speed")
      locationObject.setValue(location.timestamp, forKey: "timestamp")

      managedLocations.append(locationObject)
    }
    return managedLocations
  }

  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let trip = currentTrip {
      let trimmedLocations = locations.filter { (location) -> Bool in
        let tripBeforeLocation = trip.createdAt.compare(location.timestamp) == .OrderedAscending
        return tripBeforeLocation  && location.horizontalAccuracy < 50.0
      }
      trip.addLocations(trimmedLocations)
      if !trimmedLocations.isEmpty {
        speedObserver.sendNext(trimmedLocations.last!.speed)
      }
    }
  }

}
