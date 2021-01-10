//
//  api.swift
//  Watch Extension
//
//  Created by yanxiang.zyx on 2020/12/15.
//  Copyright © 2020 Mic Pringle. All rights reserved.
//

import Foundation


class Api {
  var apiHost = "http://192.168.1.153:3000"
  
  struct HRData: Codable {
    let val: Double
    let timestamp: String
  }


  func post(_ val:Double, _ timestamp: String, _ path: String = "/heartrate") {
    let order = HRData(val: val, timestamp: timestamp)
    guard let uploadData = try? JSONEncoder().encode(order) else {
      return
    }
    let url = URL(string: apiHost + path)!
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
//      if let mimeType = response.mimeType,
//        mimeType == "application/json",
//        let data = data,
//        let dataString = String(data: data, encoding: .utf8) {
//        print ("api return data: \(dataString)")

//      }
    }
    task.resume()
  }
}
