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

class ButtonsView: UIView {

	var delegate: ButtonsMenuDelegate?

	private let stackView: UIStackView

	override init(frame: CGRect) {
		let flashButton = UIButton(type: .custom)
		flashButton.setImage(UIImage(systemName: "bolt.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)), for: .normal)
		flashButton.addTarget(delegate, action: #selector(delegate?.toggleTorch(sender:)), for: .touchDown)

		let copyButton = UIButton(type: .custom)
		copyButton.setImage(UIImage(systemName: "doc.text.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)), for: .normal)
		copyButton.addTarget(delegate, action: #selector(delegate?.copyColorData(sender:)), for: .touchDown)

		stackView = UIStackView(arrangedSubviews: [flashButton, copyButton])
		stackView.translatesAutoresizingMaskIntoConstraints = false

		super.init(frame: frame)
		backgroundColor = .white
		clipsToBounds = true
		layer.cornerRadius = 25
		for subview in stackView.arrangedSubviews {
			NSLayoutConstraint.activate([
				subview.widthAnchor.constraint(equalToConstant: 50),
				subview.heightAnchor.constraint(equalToConstant: 50)
			])
			subview.tintColor = .lightGray
			(subview as! UIButton).adjustsImageWhenHighlighted = false
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
