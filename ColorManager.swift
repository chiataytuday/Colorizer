//
//  ColorManager.swift
//  Tint
//
//  Created by debavlad on 14.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class ColorManager {
	static let shared = ColorManager()
	var colors: [UIColor]

	private init() {
		colors = [.systemRed, .systemGreen, .systemBlue, .systemPink, .systemTeal, .systemIndigo, .systemOrange, .systemYellow]
	}
}

