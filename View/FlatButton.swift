//
//  FlatButton.swift
//  Colorizer
//
//  Created by debavlad on 15.06.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

final class FlatButton: UIButton {

	private var saved = false

	init(_ title: String, _ systemImageName: String) {
		super.init(frame: .zero)
		backgroundColor = .black
		layer.cornerRadius = 25
		setTitle(title, for: .normal)
		adjustsImageWhenHighlighted = false

		let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
		setPreferredSymbolConfiguration(config, forImageIn: .normal)
		let image = UIImage(systemName: systemImageName)
		setImage(image!, for: .normal)
		imageView?.tintColor = .white
		imageEdgeInsets.left = -7

		setTitleColor(.white, for: .normal)
		titleEdgeInsets.right = -5

		addTarget(self, action: #selector(touchDown), for: .touchDown)
		addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchUpOutside])
	}

	@objc private func touchDown() {
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .allowUserInteraction, animations: {
			self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
		})
	}

	func setVisible(_ isVisible: Bool) {
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .allowUserInteraction, animations: {
			self.transform = isVisible ? CGAffineTransform(scaleX: 0.9, y: 0.9).translatedBy(x: 0, y: 10) : .identity
		})
		UIViewPropertyAnimator(duration: 0.1, curve: .easeOut) {
			self.alpha = isVisible ? 0 : 1
		}.startAnimation()
	}

	@objc private func touchUp() {
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
			self.transform = .identity
		})
		setState(activated: saved)
		saved = !saved
		UIImpactFeedbackGenerator().impactOccurred(intensity: 0.5)
	}

	@objc private func setState(activated: Bool = false) {
		let image = UIImage(systemName: activated ? "suit.heart" : "suit.heart.fill")
		setImage(image, for: .normal)
		if !activated {
			setTitle("Saved", for: .normal)
			setTitleColor(.black, for: .normal)
			imageView?.tintColor = .black
		} else {
			setTitle("Save", for: .normal)
			setTitleColor(.lightGray, for: .normal)
			imageView?.tintColor = .lightGray
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
