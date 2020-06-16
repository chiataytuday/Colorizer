//
//  GalleryViewController.swift
//  Colorizer
//
//  Created by debavlad on 13.06.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit
import Photos

class LibraryViewController: UIViewController {

	private var libraryManager = LibraryManager()

	private let imagesCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.backgroundColor = .white
		collectionView.showsVerticalScrollIndicator = false
		collectionView.alwaysBounceVertical = true
		return collectionView
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		setupCollectionView()
		setupNavigationBar()
	}

	private func setupCollectionView() {
		imagesCollectionView.delegate = self
		imagesCollectionView.dataSource = self
		imagesCollectionView.register(ImageViewCell.self, forCellWithReuseIdentifier: "Cell")
		imagesCollectionView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(imagesCollectionView)
		NSLayoutConstraint.activate([
			imagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			imagesCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			imagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			imagesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}

	private func setupNavigationBar() {
		let titleLabel: UILabel = UILabel()
		titleLabel.font = UIFont.systemFont(ofSize: 19, weight: .light)
		titleLabel.text = "All Photos"
		titleLabel.textColor = .black

		let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
		let chevronDown = UIImageView(image: UIImage(systemName: "chevron.down", withConfiguration: config))
		chevronDown.tintColor = .black

		let stackView = UIStackView(arrangedSubviews: [titleLabel, chevronDown])
		stackView.distribution = .equalCentering
		stackView.alignment = .center
		stackView.spacing = 8

		navigationItem.titleView = stackView
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
	}

}


extension LibraryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return libraryManager.photosAmount
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		libraryManager.fetchImage(at: indexPath.item, quality: .low) { (image) in
			let imageController = ImageController()
			imageController.image = image
			imageController.modalPresentationStyle = .fullScreen
			self.navigationController?.pushViewController(imageController, animated: true)
		}
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageViewCell
		cell.imageView.image = nil
		libraryManager.fetchImage(at: indexPath.item, quality: .low) { (image) in
			cell.imageView.image = image
		}
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let size = view.frame.width/4
		return CGSize(width: size, height: size)
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		.darkContent
	}
}
