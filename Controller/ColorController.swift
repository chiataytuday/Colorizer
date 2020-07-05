//
//  ColorController.swift
//  Tint
//
//  Created by debavlad on 05.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class ColorController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		transitioningDelegate = self
	}
}

extension ColorController: UIViewControllerTransitioningDelegate {
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return AnimationController(duration: 0.5, type: .present, direction: .vertical)
	}

	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return AnimationController(duration: 0.5, type: .dismiss, direction: .vertical)
	}
}
