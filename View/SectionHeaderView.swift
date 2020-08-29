//
//  SectionHeaderView.swift
//  Tint
//
//  Created by debavlad on 29.08.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

final class SectionHeaderView: UICollectionReusableView {
  private let iconImageView: UIImageView = {
    let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
    let image = UIImage(systemName: "archivebox", withConfiguration: config)
    let imageView = UIImageView(image: image)
    imageView.tintColor = .black
    return imageView
  }()
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "Archive"
    label.font = UIFont.systemFont(ofSize: 29, weight: .semibold)
    label.transform = CGAffineTransform(translationX: 0, y: 0.65)
    label.textColor = .black
    return label
  }()
  private let subtitleLabel: UILabel = {
    let label = UILabel()
    label.text = "Up to 200 colors can be stored here"
    label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
    label.textColor = .lightGray
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupSubviews()
  }

  private func setupSubviews() {
    addSubview(subtitleLabel)
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
      subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 22.5)
    ])

    let stackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
    stackView.alignment = .center
    stackView.axis = .horizontal
    stackView.spacing = 7.5
    addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: subtitleLabel.leadingAnchor, constant: -2.5),
      stackView.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -2)
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
