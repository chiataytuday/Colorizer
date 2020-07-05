//
//  ColorController.swift
//  Tint
//
//  Created by debavlad on 05.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class ColorController: UIViewController {

	private var colorData: [Color]? {
		didSet {
			setupSubviews()
		}
	}
	var color: UIColor? {
		didSet {
			view.backgroundColor = color
			backButton.tintColor = color
			colorData = [
				Color(spaceName: "HEX", value: "#\(color!.toHEX()!)"),
				Color(spaceName: "RGB", value: color!.toRGB()),
				Color(spaceName: "HSB", value: color!.toHSB()),
				Color(spaceName: "CMYK", value: color!.toCMYK())
			]
		}
	}
	private let backButton: UIButton = {
		let button = UIButton(type: .custom)
		button.backgroundColor = .white
		let config = UIImage.SymbolConfiguration(pointSize: 19, weight: .regular)
		let image = UIImage(systemName: "chevron.down", withConfiguration: config)
		button.setImage(image, for: .normal)
		button.layer.cornerRadius = 22.5
		button.tintColor = .lightGray
		button.imageEdgeInsets.top = 2.5
		NSLayoutConstraint.activate([
			button.widthAnchor.constraint(equalToConstant: 45),
			button.heightAnchor.constraint(equalToConstant: 45)
		])
		return button
	}()

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

	@objc private func backToCamera() {
		UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.2)
		dismiss(animated: true, completion: nil)
	}

	fileprivate func setupSubviews() {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.alignment = .leading
		stackView.axis = .vertical
		for color in colorData! {
			let colorRowView = ColorRowView(title: color.spaceName, value: color.value)
			stackView.addArrangedSubview(colorRowView)
		}
		view.addSubview(stackView)
		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17.5),
			stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -22.5)
		])
	}

	override var prefersStatusBarHidden: Bool {
		true
	}
}

extension ColorController: UIViewControllerTransitioningDelegate {
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return AnimationController(duration: 0.5, type: .present, direction: .vertical)
	}

	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return AnimationController(duration: 0.5, type: .dismiss, direction: .vertical)
	}
}
