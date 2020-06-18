//
//  ColorsViewController.swift
//  Colorizer
//
//  Created by debavlad on 18.06.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class ColorsViewController: UIViewController {

	private let chevronLeft: UIImageView = {
		let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
		let image = UIImage(systemName: "chevron.left", withConfiguration: config)
		let imageView = UIImageView(image: image)
		imageView.tintColor = .white
		return imageView
	}()

	private let colorView: UIView = {
		let view = UIView()
		view.backgroundColor = .systemRed
		return view
	}()

	private let hexLabel: UILabel = {
		let label = UILabel()
		label.text = "#FFFFFF"
		label.textColor = .white
		label.font = UIFont.monospacedFont(ofSize: 30, weight: .medium)
		return label
	}()

	private let rgbLabel: UILabel = {
		let label = UILabel()
		label.text = "255 131 17"
		label.textColor = .white
		label.font = UIFont.monospacedFont(ofSize: 20, weight: .regular)
		return label
	}()

	private let collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.register(ColorCell.self, forCellWithReuseIdentifier: "Cell")
		collectionView.backgroundColor = .clear
		collectionView.alwaysBounceVertical = true
		return collectionView
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		setupSubviews()
	}

	private func setupSubviews() {
		view.addSubview(colorView)
		colorView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			colorView.topAnchor.constraint(equalTo: view.topAnchor),
			colorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			colorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			colorView.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -15)
		])

		view.addSubview(chevronLeft)
		chevronLeft.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			chevronLeft.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 23),
			chevronLeft.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
		])

		let stackView = UIStackView(arrangedSubviews: [hexLabel, rgbLabel])
		stackView.axis = .vertical
		stackView.spacing = 6
		stackView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(stackView)
		NSLayoutConstraint.activate([
			stackView.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -23),
			stackView.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 23)
		])

		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(collectionView)
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 20),
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
	}
}

extension ColorsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 13
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as! ColorCell
		colorView.backgroundColor = cell.color
		
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ColorCell
		cell.indicatorIsHidden = indexPath.item != 7
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		10
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		10
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let size = (UIScreen.main.bounds.width - 40)/6 - 10
		return CGSize(width: size, height: size)
	}


}
