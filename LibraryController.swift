//
//  LibraryController.swift
//  Tint
//
//  Created by debavlad on 01.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class LibraryController: UIViewController {

	private let plusImageView: UIImageView = {
		let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
		let image = UIImage(systemName: "plus", withConfiguration: config)
		let imageView = UIImageView(image: image)
		imageView.tintColor = .lightGray
		return imageView
	}()
	private let scrollView = UIScrollView()
	private let doubleTapGesture = UITapGestureRecognizer()
	private var photoImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()
	private let imagePicker = UIImagePickerController()
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
		view.addSubview(plusImageView)
		plusImageView.center = view.center

		setupSubviews()
		setupDoubleTapRecognizer()
		setupImagePicker()
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		present(imagePicker, animated: true)
	}

	fileprivate func setupSubviews() {
		scrollView.delegate = self
		scrollView.isUserInteractionEnabled = false
		scrollView.contentInsetAdjustmentBehavior = .never
		scrollView.delaysContentTouches = false
		view.addSubview(scrollView)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])

		scrollView.addSubview(photoImageView)
		photoImageView.clipsToBounds = true
		photoImageView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			photoImageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			photoImageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			photoImageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			photoImageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			photoImageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
			photoImageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
		])
	}

	fileprivate func setupDoubleTapRecognizer() {
		doubleTapGesture.addTarget(self, action: #selector(handleDoubleTap(recognizer:)))
		doubleTapGesture.numberOfTapsRequired = 2
		doubleTapGesture.delaysTouchesBegan = false
		doubleTapGesture.delaysTouchesEnded = false
		scrollView.addGestureRecognizer(doubleTapGesture)
	}

	fileprivate func setupImagePicker() {
		imagePicker.delegate = self
		imagePicker.sourceType = .photoLibrary
		imagePicker.allowsEditing = false
	}

	@objc private func handleDoubleTap(recognizer: UITapGestureRecognizer) {
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

extension LibraryController: UIScrollViewDelegate {
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return photoImageView
	}

	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		let scale = scrollView.zoomScale
//		pickerView.transform = CGAffineTransform(scaleX: 1/scale, y: 1/scale)

//		guard scale <= scrollView.maximumZoomScale else {
//			paletteView.zoomLabel.text = "\((scrollView.maximumZoomScale * 10).rounded()/10)x"
//			return
//		}
//		if scale <= 1 {
//			paletteView.zoomLabel.text = "\(scrollView.minimumZoomScale)x"
//			scrollView.contentInset = .zero
//			return
//		}
//		paletteView.zoomLabel.text = "\((scale * 10).rounded()/10)x"

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

extension LibraryController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		dismiss(animated: true)
		image = info[.originalImage] as? UIImage
	}
}
