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

import UIKit
import WatchConnectivity
import Foundation
import HealthKit

class ViewController: UIViewController, WCSessionDelegate{
  
  @IBOutlet weak var displayLabel: UILabel!
  @IBOutlet weak var hostInput: UITextField!
  @IBOutlet weak var hostBtn: UIButton!
  let api = Api()
  var wcSession : WCSession! = nil
  var allLog:String = ""
  let healthStore = HKHealthStore()

  override func viewDidLoad() {
    getHealthDataAuth()
    wcSession = WCSession.default
    wcSession.delegate = self
    wcSession.activate()
    hostInput.text = api.apiHost
  }
  
  @IBAction func hostBtnTapped() {
    let newHost:String = self.hostInput.text ?? api.apiHost
    self.api.apiHost = newHost
  }
  

  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    let value = message["value"] as! String
    let timestamp = message["timestamp"] as! String
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
    let timestampFormat:String = dateFormatter.string(from: Date(timeIntervalSince1970:Double(timestamp)!))
    let log = timestampFormat + " | " + String(value)
    allLog = log + "\n" + allLog
    DispatchQueue.main.async {
      self.displayLabel.text = "\n" + self.allLog
      self.api.post(Double(value) ?? 0, timestamp)
    }
  }
  
  func getHealthDataAuth() {
    if !HKHealthStore.isHealthDataAvailable() {
      return
    }
    let allTypes = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!])
    healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
      if !success {
        print("No Authorization")
      }
    }
  }
  
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    
    // Code
    
  }
  
  func sessionDidBecomeInactive(_ session: WCSession) {
    
    // Code
    
  }
  
  func sessionDidDeactivate(_ session: WCSession) {
    
    // Code
    
  }

}
