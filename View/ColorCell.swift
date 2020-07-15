//
//  ColorCell.swift
//  Tint
//
//  Created by debavlad on 15.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class ColorCell: UICollectionViewCell {
	private let hexLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.monospacedFont(ofSize: 21, weight: .medium)
		label.text = "#000000"
		return label
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		layer.cornerRadius = 30
		setupLabel()
	}

	private func setupLabel() {
		addSubview(hexLabel)
		hexLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			hexLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			hexLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}

	func configure(with color: UIColor) {
		backgroundColor = color
		hexLabel.textColor = color.readable
		hexLabel.text = color.hex
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
