
//  HeartBeat.swift
//  hehe WatchKit Extension
//
//  Created by yanxiang.zyx on 2020/11/28.
//

import Foundation
import HealthKit


struct HRData: Codable {
  let val: Double
  let timestamp: String
}

class HealthBeat {
  let healthStore = HKHealthStore()
  var handler: ((Double, String) -> ())?
  let apiHost = "http://192.168.1.153:3000"
//  var workoutSession : HKWorkoutSession?

  init () {
  }
  
  func setupHealthKit() {
    if !HKHealthStore.isHealthDataAvailable() {
      return
    }
    let allTypes = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!])
    
    
    healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
      if !success {
        print("No Authorization")
      }
      
      guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
        // This should never fail when using a defined constant.
        fatalError("*** Unable to get the heart rate type ***")
      }
      
      
      let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { (query, completionHandler, errorOrNil) in
        if let error = errorOrNil {
          print("Error: \(error.localizedDescription)")
          return
        }
        self.getHeartRateData()
      }
      self.healthStore.execute(query)
    }
  }
  
  func getHeartRateData(){
    guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
      // This should never fail when using a defined constant.
      fatalError("*** Unable to get the heart rate type ***")
    }
    let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
//    HKObjectQueryNoLimit
//    let methodStart = Date()
    
    let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) {
      query, results, error in
      
      guard let samples = results as? [HKQuantitySample] else {
        // Handle any errors here.
        return
      }
      if (samples.count == 0) {
        return
      }
  
//      let methodFinish = Date()
//      let executionTime = methodFinish.timeIntervalSince(methodStart)
//      print("Execution time: \(executionTime)")

      let data = self.formatData(samples)
      self.sendRequest(data)
      self.handler!(data.val, data.timestamp)

    }
    self.healthStore.execute(query)
  }
  
  
  func formatData(_ samples: [HKQuantitySample]) -> HRData{
    let beat = samples[0]
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let timestamp:String = dateFormatter.string(from: beat.startDate)
    let heartRateVal = beat.quantity.doubleValue(for: HKUnit(from: "count/min"))
    return HRData(val: heartRateVal, timestamp: timestamp)
  }

  func sendRequest(_ order:HRData) {
    guard let uploadData = try? JSONEncoder().encode(order) else {
      return
    }
    let url = URL(string: apiHost + "/heartrate")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
      if let error = error {
        print ("error: \(error)")
        return
      }
      guard let response = response as? HTTPURLResponse,
            (200...299).contains(response.statusCode) else {
        print ("server error")
        return
      }
      if let mimeType = response.mimeType,
         mimeType == "application/json",
         let data = data,
         let dataString = String(data: data, encoding: .utf8) {
        print ("api return data: \(dataString)")
      }
    }
    task.resume()
  }
}

