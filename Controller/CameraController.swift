//
//  CameraController.swift
//  Colorizer
//
//  Created by debavlad on 13.06.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit
import AVFoundation

enum State {
	case enabled, disabled
}

final class CameraController: UIViewController {
	var delegate: ScrollViewDelegate?
	
	private let dot: UIImageView = {
		let config = UIImage.SymbolConfiguration(pointSize: 8, weight: .bold)
		let image = UIImage(systemName: "circle.fill", withConfiguration: config)
		let imageView = UIImageView(image: image)
		imageView.tintColor = .white
		return imageView
	}()
	private let viewfinder: UIImageView = {
		let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
		let image = UIImage(systemName: "viewfinder", withConfiguration: config)
		let imageView = UIImageView(image: image)
		imageView.tintColor = .white
		imageView.alpha = 0.25
		return imageView
	}()
	private var colorInfoView = ColorInfoView()
//	private let buttonsView = ButtonsView()
	private var torchState: State = .disabled

	private lazy var captureSession: AVCaptureSession = {
		let session = AVCaptureSession()
		session.sessionPreset = .inputPriority
		return session
	}()
	private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
		let layer = AVCaptureVideoPreviewLayer(session: self.captureSession)
		layer.videoGravity = .resizeAspectFill
		layer.frame = self.view.bounds
		return layer
	}()
	private let queue = DispatchQueue(label: "com.camera.video.queue", attributes: .concurrent)
	private var captureDevice: AVCaptureDevice?
	var previewView: UIView?

	override func viewDidLoad() {
		super.viewDidLoad()
		setupCaptureSession()
		configureDeviceFormat()
		transitioningDelegate = self

		view.layer.addSublayer(previewLayer)
		captureSession.startRunning()
		setupSubviews()
		setupButtons()

		NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
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
//			if let connection = dataOutput.connection(with: .video) {
//				connection.preferredVideoStabilizationMode = .auto
//			}
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

	@objc private func openColorController() {
		let colorController = ColorController()
		UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.2)
		colorController.color = colorInfoView.color
		colorController.modalPresentationStyle = .fullScreen
		present(colorController, animated: true)
	}

	private func setupSubviews() {
		colorInfoView = ColorInfoView()
		colorInfoView.delegate = openColorController
		colorInfoView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(colorInfoView)
		NSLayoutConstraint.activate([
			colorInfoView.widthAnchor.constraint(equalToConstant: 172),
			colorInfoView.heightAnchor.constraint(equalToConstant: 70),
			colorInfoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			colorInfoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15)
		])
		if let color = UserDefaults.standard.colorForKey("lastColor") {
			colorInfoView.set(color: color)
		}

		view.addSubview(dot)
		dot.center = view.center
		view.addSubview(viewfinder)
		viewfinder.center = view.center
	}

	private func setupButtons() {
		let flashButton = UIButton(type: .custom)
		flashButton.tintColor = .lightGray
		let config1 = UIImage.SymbolConfiguration(pointSize: 21, weight: .medium)
		flashButton.setImage(UIImage(systemName: "bolt.fill", withConfiguration: config1), for: .normal)
		flashButton.addTarget(self, action: #selector(toggleTorch(sender:)), for: .touchDown)
		flashButton.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			flashButton.widthAnchor.constraint(equalToConstant: 45),
			flashButton.heightAnchor.constraint(equalToConstant: 45)
		])

		let config2 = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
		let zoomButton = UIButton(type: .custom)
		zoomButton.tintColor = .lightGray
		zoomButton.setImage(UIImage(systemName: "arrow.down.right.and.arrow.up.left", withConfiguration: config2), for: .normal)
		zoomButton.addTarget(self, action: #selector(zoomInOut(sender:)), for: .touchDown)
		zoomButton.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			zoomButton.widthAnchor.constraint(equalToConstant: 45),
			zoomButton.heightAnchor.constraint(equalToConstant: 45)
		])
		delegate?.setViews([flashButton, zoomButton], with: 1)
	}

	override func viewWillAppear(_ animated: Bool) {
		restartCaptureSession()
	}

	override func viewWillDisappear(_ animated: Bool) {
		stopCaptureSession()
	}

	fileprivate func stopCaptureSession() {
		DispatchQueue.main.async {
			self.previewLayer.connection?.isEnabled = false
			guard self.torchState == .enabled else { return }
			do {
				try self.captureDevice?.lockForConfiguration()
				defer { self.captureDevice?.unlockForConfiguration() }
				self.captureDevice?.torchMode = .off
			} catch {
				print(error.localizedDescription)
			}
		}
	}

	fileprivate func restartCaptureSession() {
		DispatchQueue.main.async {
			self.previewLayer.connection?.isEnabled = true
			guard self.torchState == .enabled else { return }
			do {
				try self.captureDevice?.lockForConfiguration()
				defer { self.captureDevice?.unlockForConfiguration() }
				self.captureDevice?.torchMode = .on
			} catch {
				print(error.localizedDescription)
			}
		}
	}

	@objc private func willResignActive() {
		stopCaptureSession()
	}

	@objc private func didBecomeActive() {
		restartCaptureSession()
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard presentedViewController == nil else { return }
		let pickedColor = previewLayer.pickColor(at: view.center)
		UserDefaults.standard.setColor(pickedColor!, forKey: "lastColor")
		colorInfoView.set(color: pickedColor!)
		UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.5)
	}

	override var prefersStatusBarHidden: Bool {
		true
	}
}

extension CameraController: ButtonsMenuDelegate {
	func toggleTorch(sender: UIButton) {
		do {
			try captureDevice?.lockForConfiguration()
			defer { captureDevice?.unlockForConfiguration() }
			switch captureDevice!.isTorchActive {
				case true:
					captureDevice?.torchMode = .off
					torchState = .disabled
					sender.tintColor = .lightGray
				case false:
					captureDevice?.torchMode = .on
					torchState = .enabled
					sender.tintColor = .darkGray
			}
		} catch {
			print(error.localizedDescription)
		}
		UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.35)
	}

	func zoomInOut(sender: UIButton) {
		let isZoomed = captureDevice?.videoZoomFactor == 3
		let zoomScale: CGFloat = isZoomed ? 1 : 3
		sender.tintColor = isZoomed ? .lightGray : .darkGray

		do {
			try captureDevice?.lockForConfiguration()
			defer { captureDevice?.unlockForConfiguration() }
			captureDevice?.videoZoomFactor = zoomScale
		} catch {
			print(error.localizedDescription)
		}
		UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.35)
	}
}

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

extension CALayer {
    public func pickColor(at position: CGPoint) -> UIColor? {
        var pixel = [UInt8](repeatElement(0, count: 4))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        guard let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return nil
        }
        context.translateBy(x: -position.x, y: -position.y)
        render(in: context)

        return UIColor(red: CGFloat(pixel[0]) / 255.0,
                       green: CGFloat(pixel[1]) / 255.0,
                       blue: CGFloat(pixel[2]) / 255.0,
                       alpha: CGFloat(pixel[3]) / 255.0)
    }
}

extension UIColor {
	func toHEX(alpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        if components.count >= 4 {
            a = Float(components[3])
        }

        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }

	func toRGB() -> String {
		let values: (r: CGFloat, g: CGFloat, b: CGFloat) = (
			(cgColor.components![0] * 255).rounded(),
			(cgColor.components![1] * 255).rounded(),
			(cgColor.components![2] * 255).rounded()
		)
		return "\(Int(values.r)) \(Int(values.g)) \(Int(values.b))"
	}

	func toHSB() -> String {
		var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
		getHue(&h, saturation: &s, brightness: &b, alpha: &a)
		#warning("Why hue value is incorrect?")
		let rounded: (h: CGFloat, s: CGFloat, b: CGFloat) = (
			(h*100).rounded(), (s*100).rounded(), (b*100).rounded()
		)
		return "\(Int(rounded.h)) \(Int(rounded.s)) \(Int(rounded.b))"
	}

	func toCMYK() -> String {
		let r = cgColor.components![0]
		let g = cgColor.components![1]
		let b = cgColor.components![2]
		guard r != 0 && g != 0 && b != 0 else {
			return "0 0 0 100"
		}

		var c = 1 - r, m = 1 - g, y = 1 - b
		let minCMY = min(c, m, y)
		c = (c - minCMY) / (1 - minCMY)
		m = (m - minCMY) / (1 - minCMY)
		y = (y - minCMY) / (1 - minCMY)

		let rounded: (c: CGFloat, m: CGFloat, y: CGFloat, k: CGFloat) = (
			(c*100).rounded(), (m*100).rounded(), (y*100).rounded(), (minCMY*100).rounded()
		)
		return "\(Int(rounded.c)) \(Int(rounded.m)) \(Int(rounded.y)) \(Int(rounded.k))"
	}
}

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

extension CameraController: UIViewControllerTransitioningDelegate {
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return AnimationController(duration: 0.4, type: .present, direction: .horizontal)
	}

	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return AnimationController(duration: 0.4, type: .dismiss, direction: .horizontal)
	}
}
