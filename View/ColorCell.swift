//
//  ColorCell.swift
//  Tint
//
//  Created by debavlad on 15.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class ColorCell: UICollectionViewCell {
  var delegate: ColorCellDelegate?

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [.allowUserInteraction, .curveEaseOut], animations: {
      self.transform = CGAffineTransform(scaleX: 0.925, y: 0.925)
    })
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    delegate?.presentColorController(with: backgroundColor!)
    UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.allowUserInteraction, .curveLinear], animations: {
      self.transform = .identity
    })
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    touchesEnded(touches, with: event)
  }

  func configure(with color: UIColor) {
    backgroundColor = color
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
