//
//  SwitchView.swift
//  Tint
//
//  Created by debavlad on 02.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class SwitchView: UIView {

	let cameraButton: UIButton = {
		let button = UIButton(type: .custom)
		let config = UIImage.SymbolConfiguration(pointSize: 19, weight: .regular)
		let image = UIImage(systemName: "camera", withConfiguration: config)
		button.setImage(image, for: .normal)
		return button
	}()
	let libraryButton: UIButton = {
		let button = UIButton(type: .custom)
		let config = UIImage.SymbolConfiguration(pointSize: 19, weight: .regular)
		let image = UIImage(systemName: "photo", withConfiguration: config)
		button.setImage(image, for: .normal)
		return button
	}()
	private var stackView: UIStackView!

	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .white
		clipsToBounds = true
		layer.cornerRadius = 25
		
		stackView = UIStackView(arrangedSubviews: [cameraButton, libraryButton])
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
