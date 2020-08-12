//
//  APIManager.swift
//  Tint
//
//  Created by debavlad on 18.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

final class APIManager {
  static let shared = APIManager()
  private let defaults = UserDefaults.standard
  private var colors: [UIColor] = []

  func add(color: UIColor) {
    if colors.count == 100 {
      colors.removeLast()
    }
    colors.insert(color, at: 0)
    defaults.archiveColors(colors, by: "colors")
  }

  func remove(color: UIColor) {
    guard colors.contains(color) else {
      return
    }
    if let index = colors.firstIndex(of: color) {
      colors.remove(at: index)
    }
    defaults.archiveColors(colors, by: "colors")
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
  func unarchiveColors(by key: String) -> [UIColor]? {
    guard let data = data(forKey: key) else { return nil }
    do {
      guard let colors = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [UIColor] else {
        return nil
      }
      return colors
    }
  }

  func archiveColors(_ colors: [UIColor]?, by key: String) {
    var data: NSData?
    if let colors = colors {
      data = try? NSKeyedArchiver.archivedData(withRootObject: colors, requiringSecureCoding: false) as NSData
    }
    set(data, forKey: key)
    synchronize()
  }
}

extension UIColor {
  static func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
    return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
  }
}
