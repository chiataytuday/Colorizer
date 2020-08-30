//
//  ColorInfoView.swift
//  Colorizer
//
//  Created by debavlad on 13.06.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

/**
 A set of methods that allows the child view
 present the `ColorController` via parent controller.
 */
@objc protocol ColorPresenting {
  func presentColorController()
}

/**
 A view that displays picked color
 and its RGB and HEX values.

 - Note: Used in `CameraController` and `ImageController`,
         located in the top of the view.
 */
final class ColorTrackerView: UIButton {
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
    label.font = .monospacedSystemFont(ofSize: 19, weight: .light)
    label.textColor = .lightGray
    label.text = "#000000"
    return label
  }()
  private let rgbLabel: UILabel = {
    let label = UILabel()
    label.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
    label.textColor = .lightGray
    label.text = "0 0 0"
    return label
  }()
  var delegate: ColorPresenting?
  var color: UIColor? {
    return circleView.backgroundColor
  }

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

  /// Reduces view's scale on touch down.
  @objc private func touchDown() {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
      self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    })
  }

  /// Resets view's scale on touch up.
  @objc private func touchUp() {
    UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
      self.transform = .identity
    })
  }

  func configure(with color: UIColor) {
    circleView.backgroundColor = color
    hexLabel.text = color.hex
    rgbLabel.text = color.rgb
  }

  required init?(coder: NSCoder) {
    fatalError()
  }
}
