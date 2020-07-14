//
//  BarButton.swift
//  Tint
//
//  Created by debavlad on 14.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

final class BarButton: UIButton {

	var isAnimatable = false

	init(_ imageName: String) {
		super.init(frame: .zero)
		let image = UIImage(systemName: imageName)
		setImage(image, for: .normal)
		tintColor = .lightGray
		adjustsImageWhenHighlighted = false
		translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			widthAnchor.constraint(equalToConstant: 45),
			heightAnchor.constraint(equalToConstant: 45)
		])
		addTarget(self, action: #selector(touchDown), for: .touchDown)
		addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchUpOutside])
	}

	func set(size: CGFloat, weight: UIImage.SymbolWeight) {
		let config = UIImage.SymbolConfiguration(pointSize: size, weight: weight)
		setPreferredSymbolConfiguration(config, forImageIn: .normal)
	}

	@objc private func touchDown() {
		guard isAnimatable else { return }
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.45, initialSpringVelocity: 0.5, options: [.allowUserInteraction], animations: {
			self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
		})
	}

	@objc private func touchUp() {
		guard isAnimatable else { return }
		UIView.animate(withDuration: 0.55, delay: 0, usingSpringWithDamping: 0.45, initialSpringVelocity: 0.5, options: .allowUserInteraction, animations: {
			self.transform = .identity
		})
	}

	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		touchesEnded(touches, with: event)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
