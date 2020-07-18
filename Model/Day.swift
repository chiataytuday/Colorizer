//
//  Day.swift
//  Tint
//
//  Created by debavlad on 18.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class Day {
  var date: Date?
  var formattedTitle: String {
    guard !Calendar.current.isDateInToday(date!) else {
      return "Today"
    }
    guard !Calendar.current.isDateInYesterday(date!) else {
      return "Yesterday"
    }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM d"
    return dateFormatter.string(from: date!)
  }
  var colors: [UIColor]?

  init(date: Date, colors: [UIColor]) {
    self.date = date
    self.colors = colors
  }
}
