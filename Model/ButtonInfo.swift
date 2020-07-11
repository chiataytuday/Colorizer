//
//  ButtonInfo.swift
//  Tint
//
//  Created by debavlad on 09.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class ButtonInfo {
	let title: String
	let description: String
	let imageName: String

	init(imageName: String, title: String, description: String) {
		self.imageName = imageName
		self.title = title
		self.description = description
	}
}
