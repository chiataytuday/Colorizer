//
//  PreviousColorsView.swift
//  Colorizer
//
//  Created by debavlad on 18.06.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class PreviousColorsView: UIView {

	let colorsCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
		collectionView.backgroundColor = .clear
		return collectionView
	}()

	init(delegate: UIViewController) {
		super.init(frame: .zero)
		layer.cornerRadius = 33.75
		backgroundColor = .white
		colorsCollectionView.layer.cornerRadius = 23.75
		colorsCollectionView.delegate = delegate as! UICollectionViewDelegate
		colorsCollectionView.dataSource = delegate as! UICollectionViewDataSource
		setupCollectionView()
	}

	private func setupCollectionView() {
		addSubview(colorsCollectionView)
		colorsCollectionView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			colorsCollectionView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
			colorsCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
			colorsCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
			colorsCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
