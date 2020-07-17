//
//  ColorRowView.swift
//  Tint
//
//  Created by debavlad on 05.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

final class ColorRowView: UIView {
	private var titleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.roundedFont(ofSize: 20, weight: .semibold)
		return label
	}()
	private var valueLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.monospacedFont(ofSize: 18, weight: .regular)
		return label
	}()

	init(title: String, value: String) {
		super.init(frame: .zero)
		layer.cornerRadius = 15
		titleLabel.text = title
		valueLabel.text = value
		titleLabel.sizeToFit()
		valueLabel.sizeToFit()
    
    setupStackView()
	}

  func set(color: UIColor) {
    titleLabel.textColor = color
    valueLabel.textColor = color
  }

  private func setupStackView() {
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
    guard let title = titleLabel.text, let value = valueLabel.text else {
      return
    }
    let stringToCopy = "\(title)(\(value.split(separator: " ").joined(separator: ", ")))"
    UIPasteboard.general.string = stringToCopy
    UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.5)

    backgroundColor = titleLabel.textColor.withAlphaComponent(0.1)
    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
      self.backgroundColor = .clear
    })
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
