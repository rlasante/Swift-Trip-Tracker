//
//  ViewController.swift
//  LocationTracker
//
//  Created by Ryan LaSante on 11/1/15.
//  Copyright © 2015 rlasante. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var startButton: UIButton?
  @IBOutlet weak var stopButton: UIButton?
  @IBOutlet weak var speedLabel: UILabel?

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    TripManager.sharedInstance.currentSpeedSignal().observeNext { (speed) -> () in
      self.speedLabel?.text = "\(Int(speed)) MPH"
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func startTracking(sender: UIButton) {
    TripManager.sharedInstance.startTracking()
    startButton?.hidden = true
    stopButton?.hidden = false
    speedLabel?.hidden = false
  }

  @IBAction func stopTracking(sender: UIButton) {
    TripManager.sharedInstance.stopTracking()
    stopButton?.hidden = true
    speedLabel?.hidden = true
    startButton?.hidden = false
  }

}

