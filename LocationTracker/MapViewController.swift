//
//  MapViewController.swift
//  LocationTracker
//
//  Created by Ryan LaSante on 11/3/15.
//  Copyright © 2015 rlasante. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

  @IBOutlet var mapView: MKMapView!
  private var internalTrip: Trip!
  var trip: Trip! {
    didSet {
      loadTrip()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.delegate = self
    loadTrip()
  }

  func loadTrip() {
    guard mapView != nil && trip != nil else {
      return
    }
    centerOnTrip()
    var coordinates = trip.locations.map { (location) -> CLLocationCoordinate2D in
      return location.coordinate
    }
    let line = MKPolyline(coordinates: &coordinates, count: coordinates.count)
    mapView.addOverlay(line)
  }

  func centerOnTrip() {
    let region = trip.tripMKRegion
    mapView.setRegion(region, animated: true)
  }

  func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
    let polylineRenderer = MKPolylineRenderer(overlay: overlay)
    polylineRenderer.strokeColor = UIColor.blueColor()
    polylineRenderer.lineWidth = 5
    return polylineRenderer
  }

}
