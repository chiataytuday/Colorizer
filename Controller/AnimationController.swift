//
//  AnimationController.swift
//  Tint
//
//  Created by debavlad on 04.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class AnimationController: NSObject {
	private let animationDuration: Double
	private let animationType: AnimationType

	enum AnimationType {
		case present
		case dismiss
	}

	init(duration: Double, type: AnimationType) {
		animationDuration = duration
		animationType = type
	}
}

extension AnimationController: UIViewControllerAnimatedTransitioning {
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return TimeInterval(exactly: animationDuration) ?? 0
	}

	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		guard let toViewController = transitionContext.viewController(forKey: .to), let fromViewController = transitionContext.viewController(forKey: .from) else {
			transitionContext.completeTransition(false)
			return
		}
		switch animationType {
			case .present:
				transitionContext.containerView.addSubview(toViewController.view)
				presentAnimation(with: transitionContext, viewToAnimate: toViewController.view)
			case .dismiss:
				transitionContext.containerView.addSubview(toViewController.view)
				transitionContext.containerView.addSubview(fromViewController.view)
				dismissAnimation(with: transitionContext, viewToAnimate: fromViewController.view)
		}
	}

	private func presentAnimation(with transitionContext: UIViewControllerContextTransitioning, viewToAnimate: UIView) {
		viewToAnimate.clipsToBounds = true
		viewToAnimate.transform = CGAffineTransform(translationX: viewToAnimate.frame.width, y: 0)
		let duration = transitionDuration(using: transitionContext)
		UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
			viewToAnimate.transform = .identity
		}) { _ in
			transitionContext.completeTransition(true)
		}
	}

	private func dismissAnimation(with transitionContext: UIViewControllerContextTransitioning, viewToAnimate: UIView) {
		let duration = transitionDuration(using: transitionContext)
		UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
			viewToAnimate.transform = CGAffineTransform(translationX: viewToAnimate.frame.width, y: 0)
		}) { _ in
			transitionContext.completeTransition(true)
		}
	}
}
