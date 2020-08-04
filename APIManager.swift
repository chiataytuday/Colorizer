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
  private var colors: [UIColor] = [
    .systemGreen, .systemPurple, .systemIndigo, .systemBlue,
    .systemTeal, .systemPink, .systemRed, .systemOrange, .systemYellow
  ]

  func addColor(_ color: UIColor) {
    colors.insert(color, at: 0)
  }

  func fetchColors() -> [UIColor] {
    return colors
  }
}
