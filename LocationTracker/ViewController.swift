//
//  ViewController.swift
//  LocationTracker
//
//  Created by Ryan LaSante on 11/1/15.
//  Copyright © 2015 rlasante. All rights reserved.
//

import UIKit
import ReactiveCocoa

class ViewController: UIViewController {

  @IBOutlet weak var startButton: UIButton?
  @IBOutlet weak var stopButton: UIButton?
  @IBOutlet weak var speedLabel: UILabel?
  var tracking = false

  override func viewDidLoad() {
    super.viewDidLoad()
    listenForSpeedChanges()
    listenForTripCompleted()
  }

  private func listenForSpeedChanges() {
    TripManager.sharedInstance.currentSpeedSignal()
      .map { (metersPerSecond) -> Double in
        metersPerSecond * 2.23694
      }.observeNext { [weak self] (speed) -> () in
        self?.speedLabel?.text = "\(Int(speed)) MPH"
      }
  }

  private func listenForTripCompleted() {
    TripManager.sharedInstance.completedTripSignal().observeNext { [weak self] (trip) -> () in
      self?.performSegueWithIdentifier("mapSegue", sender: trip)
      self?.stopButton?.hidden = true
      self?.speedLabel?.hidden = true
      self?.speedLabel?.text = ""
      self?.startButton?.hidden = false
    }
  }

  @IBAction func startTracking(sender: UIButton) {
    TripManager.sharedInstance.startTracking()
    startButton?.hidden = true
    stopButton?.hidden = false
    speedLabel?.hidden = false
  }

  @IBAction func stopTracking(sender: UIButton) {
    TripManager.sharedInstance.stopTracking()
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "mapSegue" {
      let mapViewController = segue.destinationViewController as! MapViewController
      mapViewController.trip = sender as! Trip
    }
  }

  @IBAction func doneWithMapSegue(segue: UIStoryboardSegue) {
  }

}

