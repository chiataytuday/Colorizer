//
//  ArchiveHeaderView.swift
//  Tint
//
//  Created by debavlad on 18.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

final class ArchiveHeaderView: UICollectionReusableView {
  private let iconImageView: UIImageView = {
    let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .semibold)
    let image = UIImage(systemName: "archivebox", withConfiguration: config)
    let imageView = UIImageView(image: image)
    imageView.tintColor = .black
    return imageView
  }()
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "Archive"
    label.font = UIFont.systemFont(ofSize: 30, weight: .medium)
    label.textColor = .black
    return label
  }()
  private let subtitleLabel: UILabel = {
    let label = UILabel()
    label.text = "Last 100 colors are stored here"
    label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
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
    stackView.spacing = 8
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
