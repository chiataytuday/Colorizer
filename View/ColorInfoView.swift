//
//  ColorInfoView.swift
//  Colorizer
//
//  Created by debavlad on 13.06.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

final class ColorInfoView: UIView {

	private let colorView: UIView = {
		let view = UIView()
		view.layer.cornerRadius = 10
		view.backgroundColor = .black
		NSLayoutConstraint.activate([
			view.widthAnchor.constraint(equalToConstant: 20),
			view.heightAnchor.constraint(equalToConstant: 20)
		])
		return view
	}()

	private let hexLabel: UILabel = {
		let label = UILabel()
		label.text = "#FFFFFF"
		label.textColor = .lightGray
		label.font = UIFont.monospacedFont(ofSize: 19, weight: .light)
		return label
	}()


	init() {
		super.init(frame: .zero)
		backgroundColor = .white
		layer.cornerRadius = 25

		let stackView = UIStackView(arrangedSubviews: [colorView, hexLabel])
		stackView.spacing = 10
		addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
			stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}

	func set(color: UIColor) {
		colorView.backgroundColor = color
		hexLabel.text = "#\(color.toHex()!)"
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
