//
//  ButtonsView.swift
//  Colorizer
//
//  Created by debavlad on 21.06.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

@objc protocol ButtonsMenuDelegate {
	func toggleTorch(sender: UIButton)
//	func copyColorData(sender: UIButton)
	func zoomInOut(sender: UIButton)
}

final class ButtonsView: UIView {
	var delegate: ButtonsMenuDelegate?
	let torchButton: UIButton = {
		let button = UIButton(type: .custom)
		let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
		let image = UIImage(systemName: "bolt.fill", withConfiguration: config)
		button.setImage(image, for: .normal)
		return button
	}()
	let zoomButton: UIButton = {
		let button = UIButton(type: .custom)
		let config = UIImage.SymbolConfiguration(pointSize: 19, weight: .regular)
		let image = UIImage(systemName: "arrow.down.right.and.arrow.up.left", withConfiguration: config)
		button.setImage(image, for: .normal)
		return button
	}()
	private var stackView: UIStackView!

	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .white
		clipsToBounds = true
		layer.cornerRadius = 25
		setupStackView()
	}

	private func setupStackView() {
		torchButton.addTarget(delegate, action: #selector(delegate?.toggleTorch(sender:)), for: .touchDown)
		zoomButton.addTarget(delegate, action: #selector(delegate?.zoomInOut(sender:)), for: .touchDown)

		stackView = UIStackView(arrangedSubviews: [torchButton, zoomButton])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.distribution = .equalCentering
		for case let button as UIButton in stackView.arrangedSubviews {
			NSLayoutConstraint.activate([
				button.widthAnchor.constraint(equalToConstant: 50),
				button.heightAnchor.constraint(equalToConstant: 50)
			])
			button.adjustsImageWhenHighlighted = false
			button.tintColor = .lightGray
		}
		addSubview(stackView)
		NSLayoutConstraint.activate([
			stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
			stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
			widthAnchor.constraint(equalTo: stackView.widthAnchor),
			heightAnchor.constraint(equalTo: stackView.heightAnchor)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
