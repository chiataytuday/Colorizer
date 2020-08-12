//
//  RoundButton.swift
//  Tint
//
//  Created by debavlad on 30.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

final class RoundButton: UIButton {
  init(size: CGSize) {
    super.init(frame: CGRect(origin: .zero, size: size))
    backgroundColor = .white
    adjustsImageWhenHighlighted = false
    NSLayoutConstraint.activate([
      widthAnchor.constraint(equalToConstant: size.width),
      heightAnchor.constraint(equalToConstant: size.height)
    ])
    let radius = min(size.width, size.height)/2
    layer.cornerRadius = radius

    addTarget(self, action: #selector(touchDown(sender:)), for: .touchDown)
    addTarget(self, action: #selector(touchUp(sender:)), for: [.touchUpInside, .touchUpOutside])
  }

  @objc private func touchDown(sender: UIButton) {
    UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [.allowUserInteraction, .curveEaseOut], animations: {
      sender.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
    })
  }

  @objc private func touchUp(sender: UIButton) {
    UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {
      sender.transform = .identity
    })
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
