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
			imagesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
	}

}

extension LibraryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return libraryManager.photosAmount
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as! ImageViewCell
		guard let image = cell.imageView.image else { return }

		let imageController = ImageController()
		imageController.photoImageView.image = image
		imageController.modalPresentationStyle = .fullScreen
		present(imageController, animated: true)
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageViewCell
		
		cell.imageView.image = nil
		libraryManager.fetchImage(at: indexPath.item) { (image) in
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
		let size = view.frame.width/3
		return CGSize(width: size, height: size)
	}

}
