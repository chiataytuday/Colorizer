//
//  CopyableDataView.swift
//  Tint
//
//  Created by debavlad on 05.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

/**
 
 */

final class CopyableDataView: UIView {
  private var colorSpaceLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
    return label
  }()
  private var valueLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.monospacedFont(ofSize: 20, weight: .regular)
    return label
  }()
  
  init(title: String, value: String) {
    super.init(frame: .zero)
    colorSpaceLabel.text = title
    colorSpaceLabel.sizeToFit()
    valueLabel.text = value
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
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let title = colorSpaceLabel.text, let value = valueLabel.text else {
      return
    }
    let stringToCopy = "\(title)(\(value.split(separator: " ").joined(separator: ", ")))"
    UIPasteboard.general.string = stringToCopy
    UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.5)

    #warning("TO-DO: Change copy animation")
    backgroundColor = colorSpaceLabel.textColor.withAlphaComponent(0.15)
    UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
      self.backgroundColor = .clear
    })
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
