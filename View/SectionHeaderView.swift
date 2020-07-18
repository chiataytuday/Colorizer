//
//  SectionHeaderView.swift
//  Tint
//
//  Created by debavlad on 18.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class SectionHeaderView: UICollectionReusableView {
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "Today"
    label.font = UIFont.roundedFont(ofSize: 26, weight: .semibold)
    label.textColor = .black
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(titleLabel)
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 17.5),
      titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(with text: String) {
    titleLabel.text = text
    titleLabel.sizeToFit()
  }
}
