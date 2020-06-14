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

extension UIImageView {

	func fetchImage(asset: PHAsset, targetSize: CGSize) {
		let options = PHImageRequestOptions()
		options.version = .original
		PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { (image, _) in
			guard let image = image else { return }
			self.image = image
		}
	}

}
