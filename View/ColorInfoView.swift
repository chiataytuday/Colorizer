//
//  ColorInfoView.swift
//  Colorizer
//
//  Created by debavlad on 13.06.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

@objc protocol ColorInfoDelegate {
  func presentColorController()
}

final class ColorInfoView: UIButton {
  private let circleView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 10
    view.backgroundColor = .black
    NSLayoutConstraint.activate([
      view.widthAnchor.constraint(equalToConstant: 20),
      view.heightAnchor.constraint(equalToConstant: 20)
    ])
    return view
  }()
  private let hexLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.monospacedFont(ofSize: 19, weight: .light)
    label.text = "#000000"
    label.textColor = .lightGray
    return label
  }()
  private let rgbLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.monospacedFont(ofSize: 14, weight: .regular)
    label.text = "0 0 0"
    label.textColor = .lightGray
    return label
  }()
  var color: UIColor? {
    return circleView.backgroundColor
  }
  var delegate: ColorInfoDelegate?

  init() {
    super.init(frame: .zero)
    backgroundColor = .white
    layer.cornerRadius = 35
    setupStackView()

    addTarget(self, action: #selector(touchDown), for: .touchDown)
    addTarget(delegate, action: #selector(delegate?.presentColorController), for: .touchUpInside)
    addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchUpOutside])
  }

  private func setupStackView() {
    let hexStackView = UIStackView(arrangedSubviews: [circleView, hexLabel])
    hexStackView.spacing = 10

    let stackView = UIStackView(arrangedSubviews: [hexStackView, rgbLabel])
    stackView.axis = .vertical
    stackView.spacing = 6
    stackView.alignment = .center
    addSubview(stackView)
    stackView.isUserInteractionEnabled = false
    stackView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
      stackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 2)
    ])
  }

  @objc private func touchDown() {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
      self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    })
  }

  @objc private func touchUp() {
    UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
      self.transform = .identity
    })
  }

  func set(color: UIColor) {
    circleView.backgroundColor = color
    hexLabel.text = color.hex
    rgbLabel.text = color.rgb
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UIFont
extension UIFont {
  static func monospacedFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
    guard let descriptor = UIFont.systemFont(ofSize: size, weight: weight).fontDescriptor.withDesign(.monospaced) else {
      return .systemFont(ofSize: size, weight: weight)
    }
    return UIFont(descriptor: descriptor, size: size)
  }

  static func roundedFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
    guard let descriptor = UIFont.systemFont(ofSize: size, weight: weight).fontDescriptor.withDesign(.rounded) else {
      return .systemFont(ofSize: size, weight: weight)
    }
    return UIFont(descriptor: descriptor, size: size)
  }
}
