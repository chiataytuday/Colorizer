//
//  ToolBar.swift
//  Colorizer
//
//  Created by debavlad on 16.06.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

final class PaletteView: UIView {

	private let zoomLabel: UILabel = {
		let label = UILabel()
		label.text = "1.0x"
		label.textColor = .black
		return label
	}()

	private let saveImageView: UIImageView = {
		let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
		let image = UIImage(systemName: "suit.heart", withConfiguration: config)
		let imageView = UIImageView(image: image)
		imageView.tintColor = .black
		return imageView
	}()

	private let infoImageView: UIImageView = {
		let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
		let image = UIImage(systemName: "info", withConfiguration: config)
		let imageView = UIImageView(image: image)
		imageView.tintColor = .black
		return imageView
	}()


	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = UIColor(white: 0.98, alpha: 1)
		setupSubviews()
	}

	private func setupSubviews() {
		let stackView = UIStackView(arrangedSubviews: [zoomLabel, saveImageView, infoImageView])
		stackView.distribution = .equalCentering
		stackView.alignment = .center
		stackView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(stackView)
		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
			stackView.topAnchor.constraint(equalTo: topAnchor, constant: 15)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
