//
//  BarButton.swift
//  Tint
//
//  Created by debavlad on 14.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

final class BarButton: UIButton {

	init(_ imageName: String) {
		super.init(frame: .zero)
		let image = UIImage(systemName: imageName)
		setImage(image, for: .normal)
    setupAppearance()
	}

  private func setupAppearance() {
    tintColor = .lightGray
    adjustsImageWhenHighlighted = false
    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      widthAnchor.constraint(equalToConstant: 45),
      heightAnchor.constraint(equalToConstant: 45)
    ])
    addTarget(self, action: #selector(magnify), for: .touchDown)
    addTarget(self, action: #selector(reset), for: [.touchUpInside, .touchUpOutside])
  }

	func set(size: CGFloat, weight: UIImage.SymbolWeight) {
		let config = UIImage.SymbolConfiguration(pointSize: size, weight: weight)
		setPreferredSymbolConfiguration(config, forImageIn: .normal)
	}

	@objc private func magnify() {
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.45, initialSpringVelocity: 0.5, options: .allowUserInteraction, animations: {
			self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
		})
	}

	@objc private func reset() {
		UIView.animate(withDuration: 0.55, delay: 0, usingSpringWithDamping: 0.45, initialSpringVelocity: 0.5, options: .allowUserInteraction, animations: {
			self.transform = .identity
		})
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
