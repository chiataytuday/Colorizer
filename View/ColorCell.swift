//
//  ColorCell.swift
//  Tint
//
//  Created by debavlad on 15.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class ColorCell: UICollectionViewCell {
  private let hexLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.monospacedFont(ofSize: 21, weight: .medium)
    label.text = "#000000"
    return label
  }()
  private let rgbLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.monospacedFont(ofSize: 15, weight: .medium)
    label.text = "255 0 41"
    label.alpha = 0.65
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    layer.cornerRadius = 30
    setupStackView()
  }

  private func setupStackView() {
    let stackView = UIStackView(arrangedSubviews: [hexLabel, rgbLabel])
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.spacing = 2
    stackView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(stackView)
    NSLayoutConstraint.activate([
      stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
      stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
  }

  func configure(with color: UIColor) {
    backgroundColor = color
    hexLabel.textColor = color.readable
    rgbLabel.textColor = color.readable
    hexLabel.text = color.hex
    rgbLabel.text = color.rgb
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
