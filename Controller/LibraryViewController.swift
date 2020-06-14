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

	var collectionView: UICollectionView!

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		fetchPhotos()
		setupCollectionView()
	}

	var images = [UIImage]()

	func fetchPhotos() {
		let imageManager = PHImageManager()

		let requestOptions = PHImageRequestOptions()
		requestOptions.deliveryMode = .highQualityFormat
		requestOptions.isSynchronous = true

		let targetSize = CGSize(width: view.frame.width, height: view.frame.width)

		let fetchOptions = PHFetchOptions()
		fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

		let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
		if fetchResult.count > 0 {
			for i in 0..<fetchResult.count {
				imageManager.requestImage(for: fetchResult.object(at: i), targetSize: targetSize, contentMode: .aspectFill, options: requestOptions) { image, _ in
					self.images.append(image!)
				}
			}
		} else {
			print("You got no photos :(")
			self.collectionView.reloadData()
		}
	}

	func setupCollectionView() {
		let layout = UICollectionViewFlowLayout()
		collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.backgroundColor = .white
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.showsVerticalScrollIndicator = false
		collectionView.register(ImageViewCell.self, forCellWithReuseIdentifier: "Cell")
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.alwaysBounceVertical = true
		view.addSubview(collectionView)
		NSLayoutConstraint.activate([
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
	}
}

extension LibraryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return images.count
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as! ImageViewCell
		let image = cell.imageView.image!
		let imageController = ImageController()
		imageController.photoImageView.image = image
		imageController.modalPresentationStyle = .fullScreen
		present(imageController, animated: true)
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		#error("Async here: from library or cache")
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageViewCell
		cell.imageView.image = images[indexPath.item]
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
