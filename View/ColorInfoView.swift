//
//  ColorInfoView.swift
//  Colorizer
//
//  Created by debavlad on 13.06.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class ColorInfoView: UIView {

	let squareView: UIView = {
		let view = UIView()
		view.layer.cornerRadius = 10
		NSLayoutConstraint.activate([
			view.widthAnchor.constraint(equalToConstant: 20),
			view.heightAnchor.constraint(equalToConstant: 20)
		])
		return view
	}()

	let hexLabel: UILabel = {
		let label = UILabel()
		label.text = "#FFFFFF"
		label.textColor = .lightGray
		label.font = UIFont.monospacedFont(ofSize: 18, weight: .regular)
		return label
	}()


	init(_ color: UIColor, _ hex: String) {
		super.init(frame: .zero)
		backgroundColor = .white
		layer.cornerRadius = 25

		squareView.backgroundColor = color
		hexLabel.text = "#\(hex)"

		let stackView = UIStackView(arrangedSubviews: [squareView, hexLabel])
		stackView.spacing = 12
		addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
			stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension UIFont {

	static func monospacedFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
		if let descriptor = UIFont.systemFont(ofSize: size, weight: weight).fontDescriptor.withDesign(.monospaced) {
			return UIFont(descriptor: descriptor, size: size)
		} else {
			return UIFont.systemFont(ofSize: size)
		}
	}
}
