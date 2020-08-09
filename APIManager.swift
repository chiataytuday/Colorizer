//
//  APIManager.swift
//  Tint
//
//  Created by debavlad on 18.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

/**
 
 */

class APIManager {
  static let shared = APIManager()
  private let defaults = UserDefaults.standard
  private var colors: [UIColor] = []

  func add(color: UIColor) {
    if colors.count == 100 {
      colors.removeLast()
    }
    colors.insert(color, at: 0)
    defaults.setColors(colors: colors, forKey: "colors")
  }

  func remove(color: UIColor) {
    guard colors.contains(color) else { return }
    if let index = colors.firstIndex(of: color) {
      colors.remove(at: index)
    }
    defaults.setColors(colors: colors, forKey: "colors")
  }

  func set(colors: [UIColor]) {
    self.colors = colors
  }

  func contains(color: UIColor) -> Bool {
    colors.contains(color)
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

extension UIColor {
  static func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
    return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
  }
}
