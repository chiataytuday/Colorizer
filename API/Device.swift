//
//  Device.swift
//  Tint
//
//  Created by debavlad on 05.08.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit
import AVFoundation

final class Device {
  static let shared = Device()

  var cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
  var hasNotch = false
  var barTop: CGFloat = 0

  func refreshCameraStatus() {
    cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
  }
}
