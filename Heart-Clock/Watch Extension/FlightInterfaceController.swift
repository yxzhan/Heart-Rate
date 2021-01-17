/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import WatchKit
import Foundation
import HealthKit
import WatchConnectivity


class FlightInterfaceController: WKInterfaceController, HKWorkoutSessionDelegate, WCSessionDelegate {
  
  @IBOutlet var timeLabel: WKInterfaceLabel!
  @IBOutlet var heartRateLabel: WKInterfaceLabel!
  @IBOutlet var startStopBtn: WKInterfaceButton!

  let healthStore = HKHealthStore()
  var workoutActive = false
  // define the activity type and location
  var session : HKWorkoutSession?
  var wcSession : WCSession!
  let heartRateUnit = HKUnit(from: "count/min")
  var currenQuery : HKQuery?
  let api:Api = Api()
  let defaults = UserDefaults.standard



  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
  }
  
  override func willActivate() {
    super.willActivate()
    if let str = defaults.string(forKey: "host") {
      self.api.apiHost = str
    }
  
    wcSession = WCSession.default
    wcSession.delegate = self
    wcSession.activate()

    guard HKHealthStore.isHealthDataAvailable() == true else {
      displayNotAllowed()
      return
    }
    
    guard let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
      displayNotAllowed()
      return
    }
    
    let dataTypes = Set(arrayLiteral: quantityType)
    healthStore.requestAuthorization(toShare: nil, read: dataTypes) { (success, error) -> Void in
      if success == false {
        self.displayNotAllowed()
      }
    }
  }

  func displayNotAllowed() {
    timeLabel.setText("not allowed")
  }

  func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
    switch toState {
    case .running:
      workoutDidStart(date)
    case .ended:
      workoutDidEnd(date)
    default:
      print("Unexpected state \(toState)")
    }
  }

  func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
    // Do nothing for now
    print("Workout error")
  }

  func workoutDidStart(_ date : Date) {
    if let query = createHeartRateStreamingQuery(date) {
      self.currenQuery = query
      healthStore.execute(query)
    } else {
      timeLabel.setText("cannot start")
    }
  }
  
  func workoutDidEnd(_ date : Date) {
    healthStore.stop(self.currenQuery!)
    session = nil
  }

  func startWorkout() {
    
    // If we have already started the workout, then do nothing.
    if (session != nil) {
      return
    }
    
    // Configure the workout session.
    let workoutConfiguration = HKWorkoutConfiguration()
    workoutConfiguration.activityType = .crossTraining
    workoutConfiguration.locationType = .indoor
    
    do {
      session = try HKWorkoutSession(configuration: workoutConfiguration)
      session?.delegate = self
    } catch {
      fatalError("Unable to create the workout session!")
    }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss"
    let timestamp:String = dateFormatter.string(from: Date())
    self.timeLabel.setText(timestamp)
    healthStore.start(self.session!)
  }
  
  func createHeartRateStreamingQuery(_ workoutStartDate: Date) -> HKQuery? {
    guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else { return nil }
    
    let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictEndDate )
    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[datePredicate])

    let heartRateQuery = HKAnchoredObjectQuery(type: quantityType, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
      self.updateHeartRate(sampleObjects)
    }

    heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
      self.updateHeartRate(samples)
    }
    return heartRateQuery
  }
  
  
  func updateHeartRate(_ samples: [HKSample]?) {
    guard let heartRateSamples = samples as? [HKQuantitySample] else {return}
    DispatchQueue.main.async {
      guard let sample = heartRateSamples.first else{return}
      let value = sample.quantity.doubleValue(for: self.heartRateUnit)
//      let dateFormatter = DateFormatter()
//      dateFormatter.dateFormat = "HH:mm:ss"
//      dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
//      let timestamp:String = dateFormatter.string(from: sample.startDate)
      
      DispatchQueue.main.async {
        self.heartRateLabel.setText(String(UInt16(value)))
//        self.timeLabel.setText(timestamp)
      }

      self.api.post(value, String(sample.startDate.timeIntervalSince1970))

//      print("From watch" + timestamp + " | " + String(value))
//      let message = ["action":"update", "value": String(value), "timestamp":String(sample.startDate.timeIntervalSince1970)]
//      self.wcSession.sendMessage(message, replyHandler: nil) { (error) in
//        print(error.localizedDescription)
//      }
    }
  }
  // MARK: WCSession Methods
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    let action = message["action"] as! String
    let value = message["value"] as! String
    if action == "update_host" {
      self.defaults.set(value, forKey: "host")
      self.api.apiHost = value
    }
  }
  
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
  }

  
  // MARK: - Actions
  @IBAction func startBtnTapped() {
    if (self.workoutActive) {
      //finish the current workout
      self.workoutActive = false
      self.startStopBtn.setTitle("Start")
      if let workout = self.session {
        healthStore.end(workout)
      }
      self.api.post(0, "", "/stopworkout")

//      self.wcSession.sendMessage(["action":"stop"], replyHandler: nil) { (error) in
//        print(error.localizedDescription)
//      }
    } else {
      //start a new workout
      self.workoutActive = true
      self.startStopBtn.setTitle("Stop")
      startWorkout()
      self.api.post(0, "", "/startworkout")
//      self.wcSession.sendMessage(["action":"start"], replyHandler: nil) { (error) in
//        print(error.localizedDescription)
//      }
    }
  }
  
}
