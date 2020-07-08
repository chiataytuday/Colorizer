//
//  MenuButton.swift
//  Tint
//
//  Created by debavlad on 08.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class MenuButton: UIButton {

	var delegate: (() -> ())?

	init(text: String, imageName: String) {
		super.init(frame: .zero)
		setTitle(text, for: .normal)
		let config = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
		let image = UIImage(systemName: imageName, withConfiguration: config)
		setImage(image, for: .normal)
		setupAppearance()

		addTarget(self, action: #selector(openController), for: .touchUpInside)
	}

	fileprivate func setupAppearance() {
		titleLabel?.font = UIFont.roundedFont(ofSize: 25, weight: .light)
		let color: UIColor = .gray
		setTitleColor(color, for: .normal)
		tintColor = color
		contentHorizontalAlignment = .leading
		imageEdgeInsets.left = 12
		titleEdgeInsets.left = 24
		NSLayoutConstraint.activate([
			heightAnchor.constraint(equalToConstant: 50),
			widthAnchor.constraint(equalToConstant: 200)
		])
	}

	@objc fileprivate func openController() {
		delegate?()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
