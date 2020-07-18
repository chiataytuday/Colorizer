//
//  APIManager.swift
//  Tint
//
//  Created by debavlad on 18.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class APIManager {
  static let shared = APIManager()

  func getTestDays() -> [Day] {
    let testDays = [
      Day(date: Date(), colors: [.systemRed, .systemGreen, .systemBlue, .systemPink, .systemTeal, .systemOrange, .systemYellow]),
      Day(date: Date.random(in: 20), colors: [.systemGray4, .systemIndigo, .systemPurple]),
      Day(date: Date.random(in: 10), colors: [.secondarySystemFill])
    ]
    return testDays
  }
}

//MARK: - Date
extension Date {
    static func random(in range: Int) -> Date {
        // Get the interval for the current date
        let interval =  Date().timeIntervalSince1970
        // There are 86,400 milliseconds in a day (ignoring leap dates)
        // Multiply the 86,400 milliseconds against the valid range of days
        let intervalRange = Double(86_400 * range)
        // Select a random point within the interval range
        let random = Double(arc4random_uniform(UInt32(intervalRange)) + 1)
        // Since this can either be in the past or future, we shift the range
        // so that the halfway point is the present
        let newInterval = interval + (random - (intervalRange / 2.0))
        // Initialize a date value with our newly created interval
        return Date(timeIntervalSince1970: newInterval)
    }
}
