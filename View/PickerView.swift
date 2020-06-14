//
//  PickerView.swift
//  Colorizer
//
//  Created by debavlad on 14.06.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class PickerView: UIView {

	var delegate: Notifiable!

	var touchOffset: CGPoint?
	var lastLocation = CGPoint(x: 0, y: 0)

	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .none
		layer.cornerRadius = frame.height/2
		layer.borderColor = UIColor.white.cgColor
		layer.borderWidth = 1
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowRadius = 3
		layer.shadowOpacity = 0.25
		layer.shadowOffset = CGSize(width: 0, height: 0)

		let panRecognizer = UIPanGestureRecognizer(target: self, action:#selector(detectPan))
		panRecognizer.delaysTouchesBegan = false
		self.gestureRecognizers = [panRecognizer]
	}

	@objc func detectPan(_ recognizer: UIPanGestureRecognizer) {
		switch recognizer.state {
			case .began:
				lastLocation = self.center
			case .changed:
				let translation = recognizer.translation(in: self.superview)
				self.center = CGPoint(x: lastLocation.x + translation.x * 1.05, y: lastLocation.y + translation.y * 1.05)
				let imageView = superview as! UIImageView
				let color = imageView.layer.pickColor(at: center)
				delegate.colorChanged(to: color!)
			default:
				break
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
