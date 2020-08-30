//
//  Page.swift
//  Tint
//
//  Created by debavlad on 29.08.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

final class Page {
  let controller: ScrollableViewController
  let barImageName: String

  init(_ controller: ScrollableViewController, _ barImageName: String) {
    self.controller = controller
    self.barImageName = barImageName
  }
}
