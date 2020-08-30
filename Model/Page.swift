//
//  Page.swift
//  Tint
//
//  Created by debavlad on 29.08.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

/**
 An object, which represents a single page
 of a scroll view in the `RootViewController`
 */
final class Page {
  let controller: ScrollableViewController

  /// System image image for an icon of a `BarButton`.
  let barImageName: String

  init(_ controller: ScrollableViewController, _ barImageName: String) {
    self.controller = controller
    self.barImageName = barImageName
  }
}
