//
//  Color.swift
//  Tint
//
//  Created by debavlad on 05.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import Foundation

/**
 An object that represents color data, which is
 lately used to be displayed in `ColorDataView`.
 */
struct ColorData {
  /// "RGB", "HEX" and etc.
  let spaceName: String

  /// "0 0 0", "#FFFFFF" and etc.
  let value: String

  init(_ spaceName: String, _ value: String) {
    self.spaceName = spaceName
    self.value = value
  }
}
