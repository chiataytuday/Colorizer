//
//  CopyableDataView.swift
//  Tint
//
//  Created by debavlad on 05.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

final class CopyableDataView: UIView {
  private var colorSpaceLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.roundedFont(ofSize: 20, weight: .semibold)
    return label
  }()
  private var valueLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.monospacedFont(ofSize: 18, weight: .light)
    return label
  }()

  init(with color: Color) {
    super.init(frame: .zero)
    colorSpaceLabel.text = color.spaceName
    colorSpaceLabel.sizeToFit()
    valueLabel.text = color.value
    valueLabel.sizeToFit()
    setupStackView()
  }
  
  private func setupStackView() {
    let stackView = UIStackView(arrangedSubviews: [colorSpaceLabel, valueLabel])
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.isUserInteractionEnabled = false
    stackView.axis = .vertical
    addSubview(stackView)
    NSLayoutConstraint.activate([
      heightAnchor.constraint(equalTo: stackView.heightAnchor, constant: 15),
      widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: 26),
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 13),
      stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
  }

  func set(color: UIColor) {
    colorSpaceLabel.textColor = color
    valueLabel.textColor = color
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
