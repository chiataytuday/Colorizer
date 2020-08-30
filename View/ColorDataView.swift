//
//  ColorDataView.swift
//  Tint
//
//  Created by debavlad on 30.08.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

/**
 A view that displays the
 provided color's space and value.
 */
final class ColorDataView: UIView {
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

  init(withData data: ColorData) {
    super.init(frame: .zero)
    colorSpaceLabel.text = data.spaceName
    valueLabel.text = data.value
    setupStackView()
  }

  func setLabelColor(_ color: UIColor) {
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

// MARK: - UIFont
extension UIFont {
  static func roundedFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
    guard let descriptor = UIFont.systemFont(ofSize: size, weight: weight).fontDescriptor.withDesign(.rounded) else {
      return .systemFont(ofSize: size, weight: weight)
    }
    return UIFont(descriptor: descriptor, size: size)
  }
}
