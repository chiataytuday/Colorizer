//
//  ColorController.swift
//  Tint
//
//  Created by debavlad on 05.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

final class ColorController: UIViewController {
	private var colorData: [Color]?
	private let backButton: UIButton = {
		let button = UIButton(type: .custom)
		button.adjustsImageWhenHighlighted = false
		let config = UIImage.SymbolConfiguration(pointSize: 19, weight: .medium)
		button.setPreferredSymbolConfiguration(config, forImageIn: .normal)
		let image = UIImage(systemName: "chevron.down")
		button.setImage(image, for: .normal)
		button.backgroundColor = .white
		button.tintColor = .lightGray
		button.layer.cornerRadius = 22.5
		button.imageEdgeInsets.top = 2.5
		NSLayoutConstraint.activate([
			button.widthAnchor.constraint(equalToConstant: 45),
			button.heightAnchor.constraint(equalToConstant: 45)
		])
		return button
	}()
	private var rowViews = [ColorRowView]()

	override func viewDidLoad() {
		super.viewDidLoad()
		transitioningDelegate = self

		view.addSubview(backButton)
		backButton.addTarget(self, action: #selector(backToCamera), for: .touchUpInside)
		backButton.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			backButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
			backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30)
		])
	}

	func set(color: UIColor) {
		view.backgroundColor = color
		backButton.tintColor = color
		colorData = [
			Color(spaceName: "HEX", value: color.hex),
			Color(spaceName: "RGB", value: color.rgb),
			Color(spaceName: "HSB", value: color.hsb),
			Color(spaceName: "CMYK", value: color.cmyk)
		]
		setupStackView()
		defineReadableColor(on: color)
	}

	private func defineReadableColor(on color: UIColor) {
		backButton.backgroundColor = color.readable
		rowViews.forEach { $0.textColor = color.readable }
	}

	private func setupStackView() {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.alignment = .leading
		stackView.axis = .vertical

		guard let data = colorData else { return }
		for color in data {
			let rowView = ColorRowView(title: color.spaceName, value: color.value)
			stackView.addArrangedSubview(rowView)
			rowViews.append(rowView)
		}
		
		view.addSubview(stackView)
		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17.5),
			stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -22.5)
		])
	}

	@objc private func backToCamera() {
		UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.2)
		dismiss(animated: true, completion: nil)
	}

	override var prefersStatusBarHidden: Bool {
		true
	}
}

extension ColorController: UIViewControllerTransitioningDelegate {
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return AnimationController(duration: 0.45, type: .present, direction: .vertical)
	}

	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return AnimationController(duration: 0.45, type: .dismiss, direction: .vertical)
	}
}

extension UIColor {
	var readable: UIColor {
		var white: CGFloat = 0
		getWhite(&white, alpha: nil)
		let readableColor: UIColor
		if white > 0.65 {
			readableColor = UIColor.black.withAlphaComponent(0.4)
		} else {
			readableColor = UIColor.white.withAlphaComponent(0.8)
		}
		return readableColor
	}
}
