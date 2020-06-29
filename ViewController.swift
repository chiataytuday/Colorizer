//
//  ViewController.swift
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

class ViewController: UIViewController {
	private let dot: UIImageView = {
		let config = UIImage.SymbolConfiguration(pointSize: 9, weight: .bold)
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
	private let buttonsView = ButtonsView()
	private var torchState: State = .disabled
	private var autoModeState: State = .disabled

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

//		previewView = UIView(frame: view.frame)
//		previewView!.layer.addSublayer(previewLayer)
//		view.addSubview(previewView!)

		view.layer.addSublayer(previewLayer)
		captureSession.startRunning()
		setupSubviews()

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
			if let connection = dataOutput.connection(with: .video) {
				connection.preferredVideoStabilizationMode = .standard
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
		colorInfoView = ColorInfoView()
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

		buttonsView.delegate = self
		buttonsView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(buttonsView)
		NSLayoutConstraint.activate([
			buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			buttonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15)
		])

		view.addSubview(dot)
		dot.center = view.center
		view.addSubview(viewfinder)
		viewfinder.center = view.center
	}

	@objc private func willResignActive() {
		captureSession.stopRunning()
		guard torchState == .enabled else { return }
		do {
			try captureDevice?.lockForConfiguration()
			defer { captureDevice?.unlockForConfiguration() }
			captureDevice?.torchMode = .off
		} catch {
			print(error.localizedDescription)
		}
	}

	@objc private func didBecomeActive() {
		updateCopyButton()
		captureSession.startRunning()
		guard torchState == .enabled else { return }
		do {
			try captureDevice?.lockForConfiguration()
			defer { captureDevice?.unlockForConfiguration() }
			captureDevice?.torchMode = .on
		} catch {
			print(error.localizedDescription)
		}
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if autoModeState == .enabled {
			tapAutoMode(sender: buttonsView.autoModeButton)
		}
		let pickedColor = previewLayer.pickColor(at: view.center)
		UserDefaults.standard.setColor(pickedColor!, forKey: "lastColor")
		colorInfoView.set(color: pickedColor!)
		UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.5)
		updateCopyButton()
	}

	override var prefersStatusBarHidden: Bool {
		true
	}
}

extension ViewController: ButtonsMenuDelegate {
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

	func tapAutoMode(sender: UIButton) {
		let enabled = autoModeState == .enabled
		sender.tintColor = enabled ? .lightGray : .darkGray
		autoModeState = enabled ? .disabled : .enabled
		UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.35)
	}

	func zoomInOut(sender: UIButton) {
		let isZoomed = captureDevice?.videoZoomFactor == 8
		let zoomScale: CGFloat = isZoomed ? 1 : 8
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

	func copyColorData(sender: UIButton) {
		let copiedString = UIPasteboard.general.string ?? ""
		guard !copiedString.elementsEqual(colorInfoView.formattedString) else { return }
		UIPasteboard.general.string = colorInfoView.formattedString
		UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.35)
		updateCopyButton()
	}

	private func updateCopyButton() {
		let copiedString = UIPasteboard.general.string ?? ""
		switch copiedString == colorInfoView.formattedString {
			case true:
				buttonsView.copyButton.setImage(UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)), for: .normal)
				buttonsView.copyButton.tintColor = .darkGray
			case false:
				buttonsView.copyButton.setImage(UIImage(systemName: "doc.text.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)), for: .normal)
				buttonsView.copyButton.tintColor = .lightGray
		}
	}
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
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
			guard self.autoModeState == .enabled else { return }

			let pickedColor = self.previewLayer.pickColor(at: self.view.center)
			UserDefaults.standard.setColor(pickedColor!, forKey: "lastColor")
			self.colorInfoView.set(color: pickedColor!)
		}
//		DispatchQueue.main.async {
//			self.previewLayer.contentsGravity = .resizeAspectFill
//		}
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
	func toHex(alpha: Bool = false) -> String? {
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

public extension UIImage {
    func getPixelColor(_ point: CGPoint) -> UIColor {
        guard let cgImage = self.cgImage else {
            return UIColor.clear
        }
        return cgImage.getPixelColor(point)
    }
}
public extension CGBitmapInfo {
    var isAlphaPremultiplied: Bool {
        let alphaInfo = CGImageAlphaInfo(rawValue: rawValue & Self.alphaInfoMask.rawValue)
        return alphaInfo == .premultipliedFirst || alphaInfo == .premultipliedLast
    }
}

public extension CGImage {

    func getPixelColor(_ point: CGPoint) -> UIColor {
		guard let pixelData = dataProvider?.data, let data = CFDataGetBytePtr(pixelData) else {
			return .clear
		}
        let x = Int(point.x)
        let y = Int(point.y)
        let w = self.width
        let h = self.height
        let index = w * y + x
        let numBytes = CFDataGetLength(pixelData)
        let numComponents = 4
        if numBytes != w * h * numComponents {
            NSLog("Unexpected size: \(numBytes) != \(w)x\(h)x\(numComponents)")
            return .clear
        }
        let isAlphaPremultiplied = bitmapInfo.isAlphaPremultiplied
		let c0 = CGFloat((data[4*index])) / 255
		let c1 = CGFloat((data[4*index+1])) / 255
		let c2 = CGFloat((data[4*index+2])) / 255
		let c3 = CGFloat((data[4*index+3])) / 255
		var r: CGFloat = 0
		var g: CGFloat = 0
		var b: CGFloat = 0
		var a: CGFloat = 0
			b = c0; g = c1; r = c2; a = c3
		if isAlphaPremultiplied && a > 0 {
			r = r / a
			g = g / a
			b = b / a
		}
		return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
