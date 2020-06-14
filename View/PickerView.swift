//
//  PickerView.swift
//  Colorizer
//
//  Created by debavlad on 14.06.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class PickerView: UIView {

	var touchOffset: CGPoint?
	var lastLocation = CGPoint(x: 0, y: 0)

	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .systemGreen
		layer.cornerRadius = frame.height/2
		layer.borderColor = UIColor.white.cgColor
		layer.borderWidth = 1

		let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(detectPan))
		self.gestureRecognizers = [panRecognizer]
	}

	@objc func detectPan(_ recognizer:UIPanGestureRecognizer) {
		let translation  = recognizer.translation(in: self.superview)
		self.center = CGPoint(x: lastLocation.x + translation.x, y: lastLocation.y + translation.y)
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.superview?.bringSubviewToFront(self)
		lastLocation = self.center
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
