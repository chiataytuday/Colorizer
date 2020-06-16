//
//  ToolBar.swift
//  Colorizer
//
//  Created by debavlad on 16.06.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class PaletteView: UIView {

	private let chevron: UIImageView = {
		let config = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
		let image = UIImage(systemName: "chevron.up", withConfiguration: config)
		let imageView = UIImageView(image: image)
		imageView.tintColor = .lightGray
		return imageView
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = UIColor(white: 0.98, alpha: 1)
		setupSubviews()
	}

	private func setupSubviews() {
		addSubview(chevron)
		chevron.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			chevron.centerXAnchor.constraint(equalTo: centerXAnchor),
			chevron.topAnchor.constraint(equalTo: topAnchor, constant: 5)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
