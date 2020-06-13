//
//  Camera.swift
//  Colorizer
//
//  Created by debavlad on 13.06.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit
import AVFoundation

final class Camera {

	var captureDevice: AVCaptureDevice!
	var captureSession = AVCaptureSession()
	var previewView: PreviewView!

	private var photoOutput = AVCapturePhotoOutput()

	init() {
		captureSession.beginConfiguration()
		captureSession.sessionPreset = .hd1920x1080

		captureDevice = bestDevice(in: .back)
		do {
			let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
			if captureSession.canAddInput(deviceInput) {
				captureSession.addInput(deviceInput)
			}
			if captureSession.canAddOutput(photoOutput) {
				captureSession.addOutput(photoOutput)
			}
		} catch {
			print(error.localizedDescription)
		}
		captureSession.commitConfiguration()

		previewView = PreviewView(session: captureSession)
		previewView.videoPreviewLayer.videoGravity = .resizeAspectFill
		previewView.videoPreviewLayer.connection?.videoOrientation = .portrait

		captureSession.startRunning()
	}

	private func bestDevice(in position: AVCaptureDevice.Position) -> AVCaptureDevice {
		let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:
		[.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera],
		mediaType: .video, position: .back)

		let devices = discoverySession.devices
		guard !devices.isEmpty else {
			fatalError("Missing capture devices.")
		}

		return devices.first!
	}

	func attachPreview(to view: UIView) {
		previewView.frame = view.frame
		view.insertSubview(previewView, at: 0)
	}
}
