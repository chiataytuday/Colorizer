//
//  CopyableDataView.swift
//  Tint
//
//  Created by debavlad on 05.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

final class RowDataView: UIView {
  private let colorSpaceLabel: UILabel = {
    let label = UILabel()
    label.font = .roundedFont(ofSize: 20, weight: .semibold)
    return label
  }()
  private let valueLabel: UILabel = {
    let label = UILabel()
    label.font = .monospacedSystemFont(ofSize: 18, weight: .light)
    return label
  }()

  init(with color: Color) {
    super.init(frame: .zero)
    colorSpaceLabel.textColor = tintColor
    colorSpaceLabel.text = color.spaceName
    valueLabel.textColor = tintColor
    valueLabel.text = color.value
    setupStackView()
  }

  func set(color: UIColor) {
    colorSpaceLabel.textColor = color
    valueLabel.textColor = color
  }

  private func setupStackView() {
    let stackView = UIStackView(arrangedSubviews: [colorSpaceLabel, valueLabel])
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    addSubview(stackView)
    NSLayoutConstraint.activate([
      heightAnchor.constraint(equalTo: stackView.heightAnchor, constant: 15),
      widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: 25),
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.5),
      stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
  }

  required init?(coder: NSCoder) {
    fatalError()
  }
}
