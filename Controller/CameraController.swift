//
//  CameraController.swift
//  Tint
//
//  Created by debavlad on 07.08.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit
import AVFoundation

final class CameraController: ScrollableViewController {
  private let captureSession = AVCaptureSession()
  private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
    let layer = AVCaptureVideoPreviewLayer(session: captureSession)
    layer.videoGravity = .resizeAspectFill
    layer.frame = view.bounds
    return layer
  }()
  private let colorTrackerView = ColorTrackerView()
  private var captureDevice: AVCaptureDevice?
  var delegate: ColorsArchiveUpdating?

  override func viewDidLoad() {
    super.viewDidLoad()
    setupCaptureSession()
    configureDeviceFormat()
    setupSubviews()

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(viewWillDisappear(_:)),
      name: UIApplication.willResignActiveNotification,
      object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(viewWillAppear(_:)),
      name: UIApplication.didBecomeActiveNotification,
      object: nil)
  }

  private func setupCaptureSession() {
    let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .back)
    guard !discoverySession.devices.isEmpty else { fatalError("Missing capture devices.") }
    captureDevice = discoverySession.devices.first!
    do {
      let deviceInput = try AVCaptureDeviceInput(device: captureDevice!)
      captureSession.beginConfiguration()
      if captureSession.canAddInput(deviceInput) {
        captureSession.addInput(deviceInput)
      }

      let dataOutput = AVCaptureVideoDataOutput()
      dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
      dataOutput.alwaysDiscardsLateVideoFrames = true
      if captureSession.canAddOutput(dataOutput) {
        captureSession.addOutput(dataOutput)
      }
      captureSession.commitConfiguration()
      let queue = DispatchQueue(label: "com.camera.video.queue", attributes: [])
      dataOutput.setSampleBufferDelegate(self, queue: queue)
    } catch {
      print(error.localizedDescription)
    }
  }

  private func configureDeviceFormat() {
    let formats = captureDevice?.formats.filter {
      $0.videoSupportedFrameRateRanges[0].maxFrameRate == 60
    }
    do {
      try captureDevice?.lockForConfiguration()
      defer { captureDevice?.unlockForConfiguration() }

      let formatId = formats!.count/2
      captureDevice?.activeFormat = formats![formatId]
      let duration = CMTime(value: 1, timescale: 60)
      captureDevice?.activeVideoMinFrameDuration = duration
      captureDevice?.activeVideoMaxFrameDuration = duration
    } catch {
      print(error.localizedDescription)
    }
  }

  private func setupSubviews() {
    previewLayer.connection?.isEnabled = false
    view.layer.addSublayer(previewLayer)
    captureSession.startRunning()

    colorTrackerView.delegate = self
    let lastColor = UserDefaults.standard.colorForKey("lastColor") ?? .black
    colorTrackerView.configure(with: lastColor)
    view.addSubview(colorTrackerView)
    colorTrackerView.translatesAutoresizingMaskIntoConstraints = false
    let topMargin: CGFloat = Device.shared.hasNotch ? 15 : 20
    NSLayoutConstraint.activate([
      colorTrackerView.widthAnchor.constraint(equalToConstant: 160),
      colorTrackerView.heightAnchor.constraint(equalToConstant: 70),
      colorTrackerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      colorTrackerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topMargin)
    ])

    let dotImageView = UIImageView(image: UIImage(systemName: "circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 8, weight: .regular)))
    dotImageView.tintColor = .white
    dotImageView.center = view.center
    view.addSubview(dotImageView)

    let rectImageView = UIImageView(image: UIImage(systemName: "viewfinder", withConfiguration: UIImage.SymbolConfiguration(pointSize: 38, weight: .regular)))
    rectImageView.tintColor = .white
    rectImageView.alpha = 0.25
    rectImageView.center = view.center
    view.addSubview(rectImageView)
  }

  override func willScrollTo() {
    super.willScrollTo()
    previewLayer.connection?.isEnabled = true
  }

  override func willScrollAway() {
    super.willScrollAway()
    previewLayer.connection?.isEnabled = false
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    guard isDisplayed else { return }
    previewLayer.connection?.isEnabled = true
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    guard isDisplayed else { return }
    previewLayer.connection?.isEnabled = false
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard presentedViewController == nil,
      let _ = previewLayer.connection else { return }

    /* Don't use view.center, because x < 0 sometimes */
    let center = CGPoint(x: view.frame.width/2, y: view.frame.height/2)

    let pickedColor = previewLayer.pickColor(at: center)
    UserDefaults.standard.setColor(pickedColor!, forKey: "lastColor")
    colorTrackerView.configure(with: pickedColor!)
    UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.5)
  }

  override var prefersStatusBarHidden: Bool {
    true
  }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    connection.videoOrientation = .portrait
    guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
    CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
    guard let baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0) else { return }
    CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))

    let width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0)
    let height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0)
    let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo: CGBitmapInfo = [
      .byteOrder32Little,
      CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
    ]

    guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
      return
    }
    guard let cgImage = context.makeImage() else { return }
    DispatchQueue.main.async {
      self.previewLayer.contents = cgImage
    }
  }
}

// MARK: - UserDefaults
extension UserDefaults {
  func setColor(_ color: UIColor, forKey key: String) {
    var colorData: NSData?
    do {
      colorData = try NSKeyedArchiver.archivedData(
        withRootObject: color,
        requiringSecureCoding: false) as NSData
    } catch {
      print(error.localizedDescription)
    }
    set(colorData, forKey: key)
  }

  func colorForKey(_ key: String) -> UIColor? {
    var colorToReturn: UIColor?
    guard let colorData = data(forKey: key) else { return nil }
    do {
      colorToReturn = try NSKeyedUnarchiver
        .unarchiveTopLevelObjectWithData(colorData) as? UIColor
    } catch {
      print(error.localizedDescription)
    }
    return colorToReturn
  }
}

// MARK: - ColorPresenting
extension CameraController: ColorPresenting {
  func presentColorController() {
    let colorController = ColorController()
    colorController.delegate = delegate
    colorController.configure(with: colorTrackerView.color!)
    colorController.modalPresentationStyle = .fullScreen
    present(colorController, animated: true)
  }
}
