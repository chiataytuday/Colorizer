//
//  ImageController.swift
//  Colorizer
//
//  Created by debavlad on 14.06.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

protocol ColorPickerDelegate {
	func beganMovement()
	func moved(to color: UIColor)
	func endedMovement()
}

class ImageController: UIViewController {

	private var pickerView: Picker!

	private var scrollView = UIScrollView()

	private var doubleTap = UITapGestureRecognizer()

	private var colorInfoView: ColorInfoView!

	private var paletteView: PaletteView!

	private var photoImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()

	var image: UIImage? {
		get {
			return photoImageView.image
		}
		set(newImage) {
			photoImageView.image = newImage
		}
	}


	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = UIColor(white: 0.95, alpha: 1)
		setupSubviews()
		setupDoubleTapRecognizer()
		setupNavigationBar()
	}

	override func viewWillAppear(_ animated: Bool) {
		let imageSize = photoImageView.image!.size
		let ratioH = imageSize.height/(view.frame.height/4)
		let ratioW = imageSize.width/(view.frame.width/4)
		scrollView.maximumZoomScale = max(max(ratioH, ratioW), 4)

		let color = photoImageView.layer.pickColor(at: view.center)
		pickerView.shapeLayer.fillColor = color!.cgColor
		moved(to: color!)
	}

	private func setupSubviews() {
		paletteView = PaletteView()
		view.addSubview(paletteView)
		paletteView.translatesAutoresizingMaskIntoConstraints = false
		paletteView.backgroundColor = .white
		NSLayoutConstraint.activate([
			paletteView.widthAnchor.constraint(equalTo: view.widthAnchor),
			paletteView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			paletteView.heightAnchor.constraint(equalToConstant: 70),
			paletteView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
		])

		scrollView.delegate = self
		scrollView.minimumZoomScale = 1.0
		scrollView.contentInsetAdjustmentBehavior = .never
		scrollView.delaysContentTouches = false
		scrollView.showsVerticalScrollIndicator = false
		scrollView.showsHorizontalScrollIndicator = false
		view.addSubview(scrollView)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: paletteView.topAnchor)
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
		navigationItem.titleView = colorInfoView

		pickerView = Picker(frame: CGRect(origin: .zero, size: CGSize(width: 35, height: 35)))
		pickerView.delegate = self
		photoImageView.addSubview(pickerView)
		photoImageView.isUserInteractionEnabled = true
		pickerView.center = view.center
	}

	private func setupDoubleTapRecognizer() {
		doubleTap.addTarget(self, action: #selector(handleDoubleTapScrollView(recognizer:)))
		doubleTap.numberOfTapsRequired = 2
		doubleTap.delaysTouchesBegan = false
		doubleTap.delaysTouchesEnded = false
		scrollView.addGestureRecognizer(doubleTap)
	}

	private func setupNavigationBar() {
		let insets = UIEdgeInsets(top: 0, left: 0, bottom: 1.5, right: 0)
		let image = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .light))?.withAlignmentRectInsets(insets)
		navigationController?.navigationBar.backIndicatorImage = image
		navigationController?.navigationBar.backIndicatorTransitionMaskImage = image
		navigationController?.navigationBar.tintColor = .black
	}

	@objc private func handleDoubleTapScrollView(recognizer: UITapGestureRecognizer) {
		if scrollView.zoomScale == 1 {
			let center = recognizer.location(in: recognizer.view)
			scrollView.zoom(to: zoomRectForScale(scale: 4, center:
				center), animated: true)
		} else {
			scrollView.setZoomScale(1, animated: true)
		}
	}

	private func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
		var zoomRect: CGRect = .zero
		zoomRect.size.height = photoImageView.frame.size.height / scale
		zoomRect.size.width  = photoImageView.frame.size.width  / scale

		let newCenter = scrollView.convert(center, from: photoImageView)
		zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
		zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
		return zoomRect
	}

	override var prefersStatusBarHidden: Bool {
		true
	}
}


extension ImageController: ColorPickerDelegate {

	func endedMovement() {
		doubleTap.isEnabled = true
		scrollView.isScrollEnabled = true
	}

	func beganMovement() {
		doubleTap.isEnabled = false
		scrollView.isScrollEnabled = false
	}

	func moved(to color: UIColor) {
		colorInfoView.set(color: color)
		pickerView.color = color
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
		if scale <= 1 {
			scrollView.contentInset = .zero
			return
		}

		guard let image = photoImageView.image else { return }
		let wRatio = photoImageView.frame.width / image.size.width
		let hRatio = photoImageView.frame.height / image.size.height
		let ratio = min(wRatio, hRatio)

		let newSize = CGSize(width: image.size.width * ratio,
							 height: image.size.height * ratio)
		let left = 0.5 * (newSize.width * scale > photoImageView.frame.width ? (newSize.width - photoImageView.frame.width) : (scrollView.frame.width - scrollView.contentSize.width))
		let top = 0.5 * (newSize.height * scale > photoImageView.frame.height ? (newSize.height - photoImageView.frame.height) : (scrollView.frame.height - scrollView.contentSize.height))

		scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
	}
}
