//
//  HistoryController.swift
//  Tint
//
//  Created by debavlad on 14.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class HistoryController: UIViewController {

	private let collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
		collectionView.backgroundColor = UIColor(white: 0.95, alpha: 1)
		return collectionView
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = UIColor(white: 0.95, alpha: 1)
		setupCollectionView()
	}

	func reloadCollectionView() {
		collectionView.reloadData()
	}

	fileprivate func setupCollectionView() {
		collectionView.delegate = self
		collectionView.dataSource = self
		view.addSubview(collectionView)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
	}
}

extension HistoryController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return ColorManager.shared.colors.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
		cell.backgroundColor = ColorManager.shared.colors[indexPath.item]
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let size = collectionView.frame.width / 5
		return CGSize(width: size, height: size)
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		0
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		0
	}
}
