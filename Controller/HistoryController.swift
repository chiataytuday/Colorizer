//
//  HistoryController.swift
//  Tint
//
//  Created by debavlad on 14.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

final class HistoryController: UIViewController {
	private let collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.register(ColorCell.self, forCellWithReuseIdentifier: "Cell")
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

	private func setupCollectionView() {
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

// MARK: - UICollectionViewDelegate
extension HistoryController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let color = ColorManager.shared.colors[indexPath.item]
		let colorController = ColorController()
		UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.2)
		colorController.set(color: color)
		colorController.modalPresentationStyle = .fullScreen
		present(colorController, animated: true)
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 8
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 8
	}
}

// MARK: - UICollectionViewDataSource
extension HistoryController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return ColorManager.shared.colors.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ColorCell
		let color = ColorManager.shared.colors[indexPath.item]
		cell.configure(with: color)
		return cell
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HistoryController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let size = (collectionView.frame.width - 38)/2
		return CGSize(width: size, height: 60)
	}
}
