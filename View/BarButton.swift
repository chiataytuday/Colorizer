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
    tintColor = .softGray
    adjustsImageWhenHighlighted = false
    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      widthAnchor.constraint(equalToConstant: 45),
      heightAnchor.constraint(equalToConstant: 45)
    ])
  }

  func set(size: CGFloat, weight: UIImage.SymbolWeight) {
    let config = UIImage.SymbolConfiguration(pointSize: size, weight: weight)
    setPreferredSymbolConfiguration(config, forImageIn: .normal)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
