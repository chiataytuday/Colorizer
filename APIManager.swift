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
  var colors: [UIColor] = [
    .systemGreen, .systemPurple, .systemIndigo, .systemBlue,
    .systemTeal, .systemPink, .systemRed, .systemOrange, .systemYellow
  ]

  func addColor(_ color: UIColor) {
    if colors.count == 100 {
      colors.removeLast()
    }
    colors.insert(color, at: 0)
    UserDefaults.standard.setColors(colors: colors, forKey: "colors")
  }

  func fetchColors() -> [UIColor] {
    return colors
  }
}

extension UserDefaults {
   func getColors(key: String) -> [UIColor]? {
    var colors: [UIColor]?
    if let colorData = data(forKey: key) {
     colors = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? [UIColor]
    }
    return colors
   }

  func setColors(colors: [UIColor]?, forKey key: String) {
    var colorData: NSData?
     if let colors = colors {
      colorData = NSKeyedArchiver.archivedData(withRootObject: colors) as NSData?
    }
    set(colorData, forKey: key)
    synchronize()
  }
}
