//
//  Trip.swift
//  LocationTracker
//
//  Created by Ryan LaSante on 11/1/15.
//  Copyright © 2015 rlasante. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import MapKit
import ReactiveCocoa

class Trip: NSObject {

  var rawPoints = [CLLocation]()
  var createdAt = NSDate()

  override init() {
    super.init()
  }

  init(object: NSManagedObject) {
    super.init()
    let locations = object.valueForKey("locations") as! Set<NSManagedObject>? ?? Set<NSManagedObject>()
    for managedLocation in locations {
      let coordinate = CLLocationCoordinate2D(latitude: managedLocation.valueForKey("lat")!.doubleValue, longitude: managedLocation.valueForKey("long")!.doubleValue)
      let altitude = managedLocation.valueForKey("altitude")!.doubleValue
      let horizontalAccuracy = managedLocation.valueForKey("horizontalAccuracy")!.doubleValue
      let verticalAccuracy = managedLocation.valueForKey("verticalAccuracy")!.doubleValue
      let course = managedLocation.valueForKey("course")!.doubleValue
      let speed = managedLocation.valueForKey("speed")!.doubleValue
      let timestamp = managedLocation.valueForKey("timestamp") as! NSDate
      let location = CLLocation(coordinate: coordinate, altitude: altitude, horizontalAccuracy: horizontalAccuracy, verticalAccuracy: verticalAccuracy, course: course, speed: speed, timestamp: timestamp)
      addLocation(location)
    }
  }

  func addLocation(location: CLLocation) {
    rawPoints.append(location)
  }

  func addLocations(locations: [CLLocation]) {
    rawPoints += locations
  }

  var locations : [CLLocation] {
    get {
      return smoothPoints()
    }
  }

  var tripMKRegion: MKCoordinateRegion {
    get {
      let (minLocation, centerLocation, maxLocation) = frameLocations()
      return MKCoordinateRegionMake(centerLocation, MKCoordinateSpanMake(maxLocation.latitude - minLocation.latitude, maxLocation.longitude - minLocation.longitude))
    }
  }

  private func smoothPoints() -> [CLLocation] {
    var smoothedPoints = [CLLocation]()
    var distances = [Int: Double?]()
    var totalDistance = 0.0
    let sortedPoints = rawPoints.sort { (firstLocation, secondLocation) -> Bool in
      firstLocation.timestamp.timeIntervalSince1970 < secondLocation.timestamp.timeIntervalSince1970
    }
    for (index, location) in sortedPoints.enumerate() {
      var nextDistance: Double?
      if index < sortedPoints.count - 1 {
        nextDistance = location.distanceFromLocation(sortedPoints[index+1])
        totalDistance += nextDistance!
      }
      distances[index] = nextDistance
    }
    // Now we have the distances to the adjacent points let's compare to average difference
    // Compare the distance traveled vs speed, could we have traveled that far in that time?
    for (i, location) in sortedPoints.enumerate() {
      // First thing first, let's check to see if could travel distance at the highest speed in time between updates
      if i >= sortedPoints.count - 1 {
        continue
      }
      let nextLocation = sortedPoints[i+1]
      let maxSpeed = location.speed > nextLocation.speed ? location.speed : nextLocation.speed
      let distanceToNext = distances[i]!!
      let secondsBetween = nextLocation.timestamp.timeIntervalSinceDate(location.timestamp)
      let isPossibleToNext = distanceToNext - location.horizontalAccuracy - nextLocation.horizontalAccuracy < maxSpeed * secondsBetween
      if isPossibleToNext {
        smoothedPoints.append(location)
      }
    }
    return smoothedPoints
  }

  let MIN_COORDINATE = -1000.0
  let MAX_COORDINATE = 1000.0

  private func frameLocations() -> (topLeft: CLLocationCoordinate2D, center: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D) {
    var locations = self.locations
    if locations.isEmpty {
      locations = self.rawPoints
    }
    var minLat = MAX_COORDINATE
    var minLong = MAX_COORDINATE
    var maxLat = MIN_COORDINATE
    var maxLong = MIN_COORDINATE

    for point in locations {
      let coordinate = point.coordinate

      if coordinate.latitude < minLat {
        minLat = coordinate.latitude
      }
      if coordinate.latitude > maxLat {
        maxLat = coordinate.latitude
      }
      if coordinate.longitude < minLong {
        minLong = coordinate.longitude
      }
      if coordinate.longitude > maxLong {
        maxLong = coordinate.longitude
      }
    }

    return (CLLocationCoordinate2DMake(minLat, minLong), CLLocationCoordinate2DMake((minLat+maxLat)/2.0, (minLong+maxLong)/2.0), CLLocationCoordinate2DMake(maxLat, maxLong))
  }

}
