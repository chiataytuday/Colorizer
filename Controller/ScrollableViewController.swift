//
//  PageController.swift
//  Tint
//
//  Created by debavlad on 30.08.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

/**
 A set of methods that notify the view controller
 about any events related to the parental scroll view.
 */
protocol ScrollableViewControllerDelegate {
  /// Notifies the view controller that its
  /// view is about to be scrolled to.
  func willScrollTo()

  /// Notifies the view controller that its
  /// view is about to be scrolled away.
  func willScrollAway()
}

class ScrollableViewController: UIViewController {
  /// A Boolean value indicating whether the view controller
  /// is currently displayed in the parental scroll view.
  var isDisplayed = false
}

@objc extension ScrollableViewController: ScrollableViewControllerDelegate {
  func willScrollTo() {
    isDisplayed = true
  }

  func willScrollAway() {
    guard isDisplayed else { return }
    isDisplayed = false
  }
}
