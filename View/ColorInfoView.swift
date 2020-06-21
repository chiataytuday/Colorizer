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

	private let rgbLabel: UILabel = {
		let label = UILabel()
		label.text = "0 0 0"
		label.textColor = .lightGray
		label.font = UIFont.monospacedFont(ofSize: 14, weight: .regular)
		return label
	}()

	var formattedString: String {
		return "\(hexLabel.text!) (\(rgbLabel.text!.split(separator: " ").joined(separator: ", ")))"
	}


	init() {
		super.init(frame: .zero)
		backgroundColor = .white
		layer.cornerRadius = 35

		let hexStackView = UIStackView(arrangedSubviews: [colorView, hexLabel])
		hexStackView.spacing = 10

		let stackView = UIStackView(arrangedSubviews: [hexStackView, rgbLabel])
		stackView.axis = .vertical
		stackView.spacing = 6
		stackView.alignment = .center
		addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
			stackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 2)
		])
	}

	func set(color: UIColor) {
		let cgColor = color.cgColor
		let values: (r: Int, g: Int, b: Int) = (
			Int(cgColor.components![0] * 255),
			Int(cgColor.components![1] * 255),
			Int(cgColor.components![2] * 255)
		)
		rgbLabel.text = "\(values.r) \(values.g) \(values.b)"
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
