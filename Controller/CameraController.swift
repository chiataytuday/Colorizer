//
//  CameraController.swift
//  Tint
//
//  Created by debavlad on 07.08.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit
import AVFoundation

final class CameraController: UIViewController {
  private lazy var captureSession: AVCaptureSession = {
    let session = AVCaptureSession()
    session.sessionPreset = .inputPriority
    return session
  }()
  private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
    let layer = AVCaptureVideoPreviewLayer(session: captureSession)
    layer.videoGravity = .resizeAspectFill
    layer.frame = view.bounds
    return layer
  }()
  private let colorTrackerView = ColorTrackerView()
  private var captureDevice: AVCaptureDevice?
  var delegate: ColorsArchiveUpdating?
  var isCurrent = false

  override func viewDidLoad() {
    super.viewDidLoad()
    setupCaptureSession()
    configureDeviceFormat()
    setupSubviews()

    NotificationCenter.default.addObserver(self, selector: #selector(viewWillDisappear(_:)), name: UIApplication.willResignActiveNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(viewWillAppear(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
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
    colorTrackerView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(colorTrackerView)
    let topMargin: CGFloat = Device.shared.hasNotch ? 15 : 20
    NSLayoutConstraint.activate([
      colorTrackerView.widthAnchor.constraint(equalToConstant: 172),
      colorTrackerView.heightAnchor.constraint(equalToConstant: 70),
      colorTrackerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      colorTrackerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topMargin)
    ])

    let color = UserDefaults.standard.colorForKey("lastColor") ?? .black
    colorTrackerView.configure(with: color)

    let dot: UIImageView = {
      let config = UIImage.SymbolConfiguration(pointSize: 8, weight: .regular)
      let image = UIImage(systemName: "circle.fill", withConfiguration: config)
      let imageView = UIImageView(image: image)
      imageView.tintColor = .white
      return imageView
    }()
    view.addSubview(dot)
    dot.center = view.center

    let viewfinder: UIImageView = {
      let config = UIImage.SymbolConfiguration(pointSize: 38, weight: .regular)
      let image = UIImage(systemName: "viewfinder", withConfiguration: config)
      let imageView = UIImageView(image: image)
      imageView.tintColor = .white
      imageView.alpha = 0.25
      return imageView
    }()
    view.addSubview(viewfinder)
    viewfinder.center = view.center
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard presentedViewController == nil else { return }
    guard let _ = previewLayer.connection else { return }

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

// MARK: - ScrollableViewDelegate
extension CameraController: ScrollableViewDelegate {
  @objc func scrollableViewWillAppear() {
    guard isCurrent else { return }
    previewLayer.connection?.isEnabled = true
  }

  @objc func scrollableViewWillDisappear() {
    guard isCurrent else { return }
    previewLayer.connection?.isEnabled = false
    isCurrent = false
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    scrollableViewWillAppear()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    previewLayer.connection?.isEnabled = false
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
      colorData = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) as NSData
    } catch {
      print(error.localizedDescription)
    }
    set(colorData, forKey: key)
  }

  func colorForKey(_ key: String) -> UIColor? {
    var colorToReturn: UIColor?
    guard let colorData = data(forKey: key) else { return nil }
    do {
      colorToReturn = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor
    } catch {
      print(error.localizedDescription)
    }
    return colorToReturn
  }
}

// MARK: - ColorInfoDelegate
extension CameraController: ColorPresenting {
  func presentColorController() {
    let colorController = ColorController()
    colorController.delegate = delegate
    colorController.configure(with: colorTrackerView.color!)
    colorController.modalPresentationStyle = .fullScreen
    present(colorController, animated: true)
  }
}
