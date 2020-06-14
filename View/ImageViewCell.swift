
//
//  ImageViewCell.swift
//  Colorizer
//
//  Created by debavlad on 14.06.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class ImageViewCell: UICollectionViewCell {

	let imageView: UIImageView

	override init(frame: CGRect) {
		imageView = UIImageView(frame: frame)
		imageView.contentMode = .scaleAspectFill
		imageView.translatesAutoresizingMaskIntoConstraints = false

		super.init(frame: frame)
		clipsToBounds = true
		addSubview(imageView)
		NSLayoutConstraint.activate([
			imageView.widthAnchor.constraint(equalTo: widthAnchor),
			imageView.heightAnchor.constraint(equalTo: heightAnchor),
			imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
			imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
