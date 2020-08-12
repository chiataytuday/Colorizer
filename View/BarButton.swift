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
    tintColor = .softGray
    adjustsImageWhenHighlighted = false
    let image = UIImage(systemName: imageName)
    setImage(image, for: .normal)
  }

  func set(size: CGFloat, weight: UIImage.SymbolWeight) {
    let config = UIImage.SymbolConfiguration(pointSize: size, weight: weight)
    setPreferredSymbolConfiguration(config, forImageIn: .normal)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
