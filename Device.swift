//
//  Device.swift
//  Tint
//
//  Created by debavlad on 05.08.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

final class Device {
  static let shared = Device()
  var hasNotch: Bool

  private init() {
    hasNotch = false
  }
}
