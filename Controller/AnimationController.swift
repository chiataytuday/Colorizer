//
//  AnimationController.swift
//  Tint
//
//  Created by debavlad on 04.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

/**
 
 */

final class AnimationController: NSObject {
  enum AnimationType {
    case present
    case dismiss
  }

  private let animationDuration: Double
  private let animationType: AnimationType

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
        presentAnimation(with: transitionContext, viewToAnimate: toViewController.view, viewFromAnimate: fromViewController.view)
      case .dismiss:
        transitionContext.containerView.addSubview(toViewController.view)
        transitionContext.containerView.addSubview(fromViewController.view)
        dismissAnimation(with: transitionContext, viewToAnimate: fromViewController.view, viewFromAnimate: toViewController.view)
    }
  }

  private func presentAnimation(with transitionContext: UIViewControllerContextTransitioning, viewToAnimate: UIView, viewFromAnimate: UIView) {
    let duration = transitionDuration(using: transitionContext)
    viewToAnimate.clipsToBounds = true

    viewToAnimate.transform = CGAffineTransform(translationX: 0, y: -viewToAnimate.frame.height)
    UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
      viewToAnimate.transform = .identity
      viewFromAnimate.transform = CGAffineTransform(translationX: 0, y: viewFromAnimate.frame.height)
    }) { _ in
      transitionContext.completeTransition(true)
    }
  }

  private func dismissAnimation(with transitionContext: UIViewControllerContextTransitioning, viewToAnimate: UIView, viewFromAnimate: UIView) {
    let duration = transitionDuration(using: transitionContext)
    UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
      viewToAnimate.transform = CGAffineTransform(translationX: 0, y: -viewToAnimate.frame.height)
      viewFromAnimate.transform = .identity
    }) { _ in
      transitionContext.completeTransition(true)
    }
  }
}
