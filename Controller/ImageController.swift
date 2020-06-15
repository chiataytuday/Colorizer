//
//  ImageController.swift
//  Colorizer
//
//  Created by debavlad on 14.06.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

protocol Notifiable {

	func movementStarted()

	func colorChanged(to color: UIColor)

	func movementFinished()
}

class ImageController: UIViewController, Notifiable {

	func movementFinished() {
		#warning("Check if color is saved")
		doubleTap.isEnabled = true
		scrollView.isScrollEnabled = true
		likeButton.setVisible(false)
	}

	func movementStarted() {
		doubleTap.isEnabled = false
		scrollView.isScrollEnabled = false
		likeButton.setVisible(true)
	}

	func colorChanged(to color: UIColor) {
		colorInfoView.set(color: color)
		pickerView.color = color
	}

	var pickerView: Picker!

	var likeButton: FlatButton!

	var scrollView = UIScrollView()

	private var colorInfoView: ColorInfoView!

	var photoImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()

	var doubleTap: UITapGestureRecognizer!

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = UIColor(white: 0.95, alpha: 1)
		setupSubviews()

		doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapScrollView(recognizer:)))
		doubleTap.numberOfTapsRequired = 2
		doubleTap.delaysTouchesBegan = false
		doubleTap.delaysTouchesEnded = false
		scrollView.addGestureRecognizer(doubleTap)
	}

	override func viewWillAppear(_ animated: Bool) {
		let imageSize = photoImageView.image!.size
		let ratioH = imageSize.height/(view.frame.height/4)
		let ratioW = imageSize.width/(view.frame.width/4)
		let ratio = max(ratioH, ratioW)
		scrollView.maximumZoomScale = max(ratio, 4)
		print("\(ratioH)")

		let color = photoImageView.layer.pickColor(at: view.center)
		colorChanged(to: color!)
		pickerView.shapeLayer.fillColor = color!.cgColor
	}

	@objc private func handleDoubleTapScrollView(recognizer: UITapGestureRecognizer) {
		if scrollView.zoomScale == 1 {
			scrollView.zoom(to: zoomRectForScale(scale: 4, center: recognizer.location(in: recognizer.view)), animated: true)
		} else {
			scrollView.setZoomScale(1, animated: true)
		}
	}

	private func setupSubviews() {
		scrollView.delegate = self
		scrollView.minimumZoomScale = 1.0
		scrollView.maximumZoomScale = 20.0
		scrollView.contentInsetAdjustmentBehavior = .never
		scrollView.delaysContentTouches = false
		scrollView.showsVerticalScrollIndicator = false
		scrollView.showsHorizontalScrollIndicator = false

		view.addSubview(scrollView)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.topAnchor.constraint(equalTo: view.topAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])

		scrollView.addSubview(photoImageView)
		photoImageView.clipsToBounds = true
		photoImageView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			photoImageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			photoImageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			photoImageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			photoImageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			photoImageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
			photoImageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
		])

		colorInfoView = ColorInfoView()
		colorInfoView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(colorInfoView)
		NSLayoutConstraint.activate([
			colorInfoView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
			colorInfoView.heightAnchor.constraint(equalToConstant: 50),
			colorInfoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			colorInfoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
		])

		pickerView = Picker(frame: CGRect(origin: .zero, size: CGSize(width: 35, height: 35)))
		pickerView.delegate = self
		photoImageView.addSubview(pickerView)
		photoImageView.isUserInteractionEnabled = true
		pickerView.center = view.center

		likeButton = FlatButton("Save", "suit.heart")
		likeButton.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(likeButton)
		NSLayoutConstraint.activate([
			likeButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
			likeButton.heightAnchor.constraint(equalToConstant: 50),
			likeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			likeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
		])
	}

	func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
		var zoomRect: CGRect = .zero
		zoomRect.size.height = photoImageView.frame.size.height / scale
		zoomRect.size.width  = photoImageView.frame.size.width  / scale
		let newCenter = scrollView.convert(center, from: photoImageView)
		zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
		zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
		return zoomRect
	}
}

extension ImageController: UIScrollViewDelegate {

	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return photoImageView
	}

	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		let scale = scrollView.zoomScale
		pickerView.transform = CGAffineTransform(scaleX: 1/scale, y: 1/scale)

		guard scale <= scrollView.maximumZoomScale else { return }
		guard scale > 1 else {
			scrollView.contentInset = .zero
			return
		}

		if let image = photoImageView.image {
			let ratioW = photoImageView.frame.width / image.size.width
			let ratioH = photoImageView.frame.height / image.size.height
			let ratio = ratioW < ratioH ? ratioW : ratioH

			let newWidth = image.size.width*ratio
			let newHeight = image.size.height*ratio

			let left = 0.5 * (newWidth * scale > photoImageView.frame.width ? (newWidth - photoImageView.frame.width) : (scrollView.frame.width - scrollView.contentSize.width))
			let top = 0.5 * (newHeight * scale > photoImageView.frame.height ? (newHeight - photoImageView.frame.height) : (scrollView.frame.height - scrollView.contentSize.height))

			scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
		}
	}
}
