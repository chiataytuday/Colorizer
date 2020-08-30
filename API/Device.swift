//
//  Device.swift
//  Tint
//
//  Created by debavlad on 05.08.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit
import AVFoundation

/// An object that contains some device properties.
final class Device {
  static let shared = Device()

  /// `RootViewController`'s navigation bar height.
  var barHeight: CGFloat {
    return 65 + bottomInset - (bottomInset > 0 ? 10 : 0)
  }

  /// Device safe area bottom inset.
  var bottomInset: CGFloat = 0

  /// A Boolean value indicating whether the device has notch.
  var hasNotch: Bool {
    return bottomInset > 0
  }

  var cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)

  func refreshCameraStatus() {
    cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
  }
}
