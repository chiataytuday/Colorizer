//
//  ColorRowView.swift
//  Tint
//
//  Created by debavlad on 05.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class ColorRowView: UIView {
	var titleLabel: UILabel = {
		let label = UILabel()
		label.textColor = .white
		label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
		return label
	}()
	var valueLabel: UILabel = {
		let label = UILabel()
		label.textColor = .white
		label.font = UIFont.monospacedFont(ofSize: 18, weight: .light)
		return label
	}()

	init(title: String, value: String) {
		super.init(frame: .zero)
		layer.cornerRadius = 15
		titleLabel.text = title
		valueLabel.text = value
		titleLabel.sizeToFit()
		valueLabel.sizeToFit()

		let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.isUserInteractionEnabled = false
		stackView.axis = .vertical
		addSubview(stackView)
		NSLayoutConstraint.activate([
			heightAnchor.constraint(equalTo: stackView.heightAnchor, constant: 15),
			widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: 25),
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.5),
			stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.5)
		UIPasteboard.general.string = valueLabel.text
		backgroundColor = .init(white: 1.0, alpha: 0.2)
		UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
			self.backgroundColor = .clear
		}, completion: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
