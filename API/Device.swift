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
  var barHeight: CGFloat {
    return 65 + bottomInset - (bottomInset > 0 ? 10 : 0)
  }
  var bottomInset: CGFloat = 0
  var hasNotch: Bool {
    return bottomInset > 0
  }

  func refreshCameraStatus() {
    cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
  }
}
