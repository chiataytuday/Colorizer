//
//  APIManager.swift
//  Colorizer
//
//  Created by debavlad on 14.06.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import Foundation
import Photos
import UIKit

typealias FetchHandler = (_ image: UIImage) -> ()

class LibraryManager {

	private var fetchResult: PHFetchResult<PHAsset>
	private var imageManager = PHImageManager()
	private var requestOptions: PHImageRequestOptions
	private var fetchOptions: PHFetchOptions
	private var targetSize: CGSize

	private var imageCache = NSCache<NSNumber, UIImage>()
	
	var photosAmount: Int {
		return fetchResult.count
	}


	init() {
		imageManager = PHImageManager()

		requestOptions = PHImageRequestOptions()
		requestOptions.deliveryMode = .highQualityFormat

		let size = UIScreen.main.bounds.width
		targetSize = CGSize(width: size, height: size)

		fetchOptions = PHFetchOptions()
		fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

		fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
		imageCache.countLimit = 300
	}

	func fetchImage(at id: Int, handler: @escaping FetchHandler) {
		if let imageInCache = imageCache.object(forKey: id as NSNumber) {
			handler(imageInCache)
//			print("\(id) cache")
		} else {
			imageManager.requestImage(for: fetchResult.object(at: id), targetSize: targetSize, contentMode: .aspectFit, options: requestOptions) { (image, _) in
				self.imageCache.setObject(image!, forKey: id as NSNumber)
				handler(image!)
//				print("\(id) library")
			}
		}
	}

}
