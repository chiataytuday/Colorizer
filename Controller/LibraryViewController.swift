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

//	var images = [UIImage]()

	var fetchResult: PHFetchResult<PHAsset>?
	var imageManager = PHImageManager()
	var requestOptions: PHImageRequestOptions!
	var fetchOptions: PHFetchOptions!
	var targetSize: CGSize!

	func fetchPhotos() {
		imageCache.countLimit = 200
		imageManager = PHImageManager()

		requestOptions = PHImageRequestOptions()
		requestOptions.deliveryMode = .highQualityFormat

		targetSize = CGSize(width: view.frame.width, height: view.frame.width)

		fetchOptions = PHFetchOptions()
		fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

		fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
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

	var imageCache = NSCache<AnyObject, AnyObject>()
}

extension LibraryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return fetchResult?.count ?? 0
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
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageViewCell
		cell.imageView.image = nil
		cell.imageView.backgroundColor = .red
		DispatchQueue.main.async {
			if let image = self.imageCache.object(forKey: indexPath.item as NSNumber) {
				cell.imageView.image = image as? UIImage
				print("\(indexPath.item) cache")
			} else {
				self.imageManager.requestImage(for: self.fetchResult!.object(at: indexPath.item), targetSize: self.targetSize, contentMode: .aspectFill, options: self.requestOptions) { (image, _) in
					self.imageCache.setObject(image!, forKey: indexPath.item as NSNumber)
					cell.imageView.image = image!
					print("\(indexPath.item) library")
				}
			}
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
