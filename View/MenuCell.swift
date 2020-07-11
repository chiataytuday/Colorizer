//
//  MenuCell.swift
//  Tint
//
//  Created by debavlad on 09.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class MenuCell: UICollectionViewCell {
	private var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.tintColor = UIColor(red: 75/255, green: 102/255, blue: 178/255, alpha: 1)
		return imageView
	}()
	private var titleLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.roundedFont(ofSize: 22, weight: .medium)
		label.textColor = UIColor(red: 75/255, green: 102/255, blue: 178/255, alpha: 1)
		return label
	}()
	private var descriptionLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.roundedFont(ofSize: 16, weight: .regular)
		label.textColor = UIColor(red: 123/255, green: 143/255, blue: 200/255, alpha: 1)
		return label
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		layer.cornerRadius = 20
		backgroundColor = UIColor(red: 233/255, green: 245/255, blue: 253/255, alpha: 1)
		setupStackView()
	}

	fileprivate func setupStackView() {
		addSubview(imageView)
		imageView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
			imageView.topAnchor.constraint(equalTo: topAnchor, constant: 15)
		])

		let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
		stackView.axis = .vertical
		stackView.spacing = 2
		addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -17),
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 17)
		])
	}

	func setupSubviews(with info: ButtonInfo) {
		let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .light)
		let image = UIImage(systemName: info.imageName, withConfiguration: config)
		imageView.image = image
		titleLabel.text = info.title
		titleLabel.sizeToFit()
		descriptionLabel.text = info.description
		descriptionLabel.sizeToFit()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
