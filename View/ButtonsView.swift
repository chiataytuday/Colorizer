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
	func copyColorData(sender: UIButton)
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
	let copyButton: UIButton = {
		let button = UIButton(type: .custom)
		let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
		let image = UIImage(systemName: "doc.text.fill", withConfiguration: config)
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
		copyButton.addTarget(delegate, action: #selector(delegate?.copyColorData(sender:)), for: .touchDown)

		stackView = UIStackView(arrangedSubviews: [torchButton, copyButton])
		stackView.translatesAutoresizingMaskIntoConstraints = false
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
