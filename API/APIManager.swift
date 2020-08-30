//
//  APIManager.swift
//  Tint
//
//  Created by debavlad on 18.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

/**
 An object that is responsible
 for color storage/management.
 */
final class APIManager {
  static let shared = APIManager()
  private let defaults = UserDefaults.standard
  private var colors: [UIColor] = []

  /// Adds the color to the collection.
  func add(color: UIColor) {
    if colors.count == 200 {
      colors.removeLast()
    }
    colors.insert(color, at: 0)
    defaults.archiveColors(colors, byKey: "colors")
  }

  /// Removes the color from the collection.
  func remove(color: UIColor) {
    guard colors.contains(color) else {
      return
    }
    if let index = colors.firstIndex(of: color) {
      colors.remove(at: index)
    }
    defaults.archiveColors(colors, byKey: "colors")
  }

  /// Replaces the colors collection.
  func set(colors: [UIColor]) {
    self.colors = colors
  }

  /// Indicates whether the collection contains a color.
  func contains(color: UIColor) -> Bool {
    colors.contains(color)
  }

  /// Returns the collection.
  func fetchColors() -> [UIColor] {
    return colors
  }
}

// MARK: - UserDefaults
extension UserDefaults {
  /**
   A method for reading `[UIColor]` from the `UserDefaults`.

   - Parameters:
      - key: A key in the current user's defaults database.
   */
  func unarchiveColors(byKey key: String) -> [UIColor]? {
    guard let data = data(forKey: key) else { return nil }
    do {
      guard let colors = try? NSKeyedUnarchiver
        .unarchiveTopLevelObjectWithData(data) as? [UIColor] else {
          return nil
      }
      return colors
    }
  }

  /**
  A method for saving `[UIColor]` to the `UserDefaults`.

  - Parameters:
     - colors: The [UIColor] value to store in the defaults database.
     - key: A key in the current user's defaults database.
  */
  func archiveColors(_ colors: [UIColor]?, byKey key: String) {
    var data: NSData?
    if let colors = colors {
      data = try? NSKeyedArchiver.archivedData(
        withRootObject: colors,
        requiringSecureCoding: false) as NSData
    }
    set(data, forKey: key)
    synchronize()
  }
}
