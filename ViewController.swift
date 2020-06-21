//
//  ViewController.swift
//  Colorizer
//
//  Created by debavlad on 13.06.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit
import AVFoundation

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

	private let copyButton: UIButton = {
		let button = UIButton(type: .custom)
		button.backgroundColor = .white
		button.setTitle("Copy color", for: .normal)
		button.setTitleColor(.lightGray, for: .normal)
		button.imageView?.tintColor = .lightGray
		button.imageEdgeInsets.left = -8
		button.titleEdgeInsets.right = -8
		button.layer.cornerRadius = 25
		button.setImage(UIImage(systemName: "doc.fill"), for: .normal)
		return button
	}()

	private var colorInfoView: ColorInfoView!

	private let captureSession = AVCaptureSession()
	private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
	private var captureDevice: AVCaptureDevice?
	private let queue = DispatchQueue(label: "com.camera.video.queue", attributes: .concurrent)


	override func viewDidLoad() {
		super.viewDidLoad()

		captureSession.sessionPreset = .hd1920x1080
		let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .back)
		guard !discoverySession.devices.isEmpty else { fatalError("Missing capture devices.") }
		captureDevice = discoverySession.devices.first!

		do {
			let videoOutput = AVCaptureVideoDataOutput()
			videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable : NSNumber(value: kCMPixelFormat_32BGRA)] as? [String : Any]
			videoOutput.alwaysDiscardsLateVideoFrames = true
			videoOutput.setSampleBufferDelegate(self, queue: queue)

			if captureSession.canAddOutput(videoOutput) {
				captureSession.addOutput(videoOutput)
			}

			let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice!)
			captureSession.addInput(captureDeviceInput)
		} catch {
			print(error.localizedDescription)
		}

		for format in captureDevice!.formats {
			if format.videoSupportedFrameRateRanges[0].maxFrameRate == 60 {
				do {
					try captureDevice?.lockForConfiguration()
					captureDevice?.activeFormat = format
					captureDevice?.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 60)
					captureDevice?.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 60)
					captureDevice?.unlockForConfiguration()
				} catch {
					print(error.localizedDescription)
				}
			}
		}

		videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		view.layer.addSublayer(videoPreviewLayer!)
		videoPreviewLayer?.videoGravity = .resizeAspectFill
		videoPreviewLayer?.frame = view.frame
		captureSession.startRunning()

		setupSubviews()
		view.addSubview(dot)
		dot.center = view.center
		view.addSubview(viewfinder)
		viewfinder.center = view.center
	}

	private func setupSubviews() {
		colorInfoView = ColorInfoView()
		colorInfoView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(colorInfoView)
		print(UIScreen.main.bounds.width * 0.415)
		NSLayoutConstraint.activate([
			colorInfoView.widthAnchor.constraint(equalToConstant: 172),
			colorInfoView.heightAnchor.constraint(equalToConstant: 70),
			colorInfoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			colorInfoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
		])

		let buttonsView = ButtonsView()
		buttonsView.delegate = self
		buttonsView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(buttonsView)
		NSLayoutConstraint.activate([
			buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			buttonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
		])
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let color = videoPreviewLayer?.pickColor(at: view.center)
		colorInfoView.set(color: color!)
		UIImpactFeedbackGenerator().impactOccurred(intensity: 0.35)
	}

	override var prefersStatusBarHidden: Bool {
		true
	}

}


extension ViewController: ButtonsMenuDelegate {

	@objc func toggleTorch(sender: UIButton) {
		do {
			try captureDevice?.lockForConfiguration()
			if captureDevice!.isTorchActive {
				captureDevice?.torchMode = .off
				sender.tintColor = .lightGray
			} else {
				captureDevice?.torchMode = .on
				sender.tintColor = .darkGray
			}
			captureDevice?.unlockForConfiguration()
		} catch {}
		UIImpactFeedbackGenerator().impactOccurred(intensity: 0.35)
	}

	func copyColorData(sender: UIButton) {
		UIPasteboard.general.string = colorInfoView.formattedString
		UIImpactFeedbackGenerator().impactOccurred(intensity: 0.35)

		sender.tintColor = .darkGray
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveLinear, .allowUserInteraction], animations: {
			sender.tintColor = .lightGray
		})
	}

}


extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
	func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
		connection.videoOrientation = .portrait

		guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
		CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
		guard let baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0) else { return }

		let width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0)
		let height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0)
		print()
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
			self.videoPreviewLayer?.contents = cgImage
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
