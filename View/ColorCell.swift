//
//  ColorCell.swift
//  Colorizer
//
//  Created by debavlad on 18.06.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class ColorCell: UICollectionViewCell {

	private let indicator: UIView = {
		let view = UIView()
		view.backgroundColor = .white
		return view
	}()

	let color: UIColor

	var indicatorIsHidden: Bool {
		set {
			indicator.isHidden = newValue
		}
		get {
			return indicator.isHidden
		}
	}

	override init(frame: CGRect) {
		color = UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)
		super.init(frame: frame)
		backgroundColor = color
		layer.cornerRadius = frame.height/2

		let indicatorSize = frame.height/3
		indicator.frame.size = CGSize(width: indicatorSize, height: indicatorSize)
		indicator.layer.cornerRadius = indicatorSize/2
		indicator.center = CGPoint(x: frame.width/2, y: frame.height/2)
		addSubview(indicator)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
