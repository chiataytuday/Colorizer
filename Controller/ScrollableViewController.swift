//
//  PageController.swift
//  Tint
//
//  Created by debavlad on 30.08.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

protocol ScrollableViewControllerDelegate {
  func willScrollTo()
  func willScrollAway()
}

class ScrollableViewController: UIViewController {
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
