//
//  AppStoreReviewManager.swift
//  Tint
//
//  Created by debavlad on 11.08.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import StoreKit

private enum Keys: String {
  case reviewActionsCount,
  lastReviewRequestAppVersion
}

enum ReviewManager {
  static let minActionsAmount = 10

  static func requestReviewIfAppropriate() {
    let defaults = UserDefaults.standard
    let bundle = Bundle.main

    var actionsCount = defaults.integer(forKey: Keys.reviewActionsCount.rawValue)
    actionsCount += 1
    defaults.set(actionsCount, forKey: Keys.reviewActionsCount.rawValue)

    guard actionsCount >= minActionsAmount else { return }
    let bundleVersionKey = kCFBundleVersionKey as String
    let currentVersion = bundle.object(forInfoDictionaryKey: bundleVersionKey) as? String
    let lastVersion = defaults.string(forKey: Keys.lastReviewRequestAppVersion.rawValue)

    guard lastVersion == nil || lastVersion != currentVersion else { return }
    SKStoreReviewController.requestReview()

    defaults.set(0, forKey: Keys.reviewActionsCount.rawValue)
    defaults.set(currentVersion, forKey: Keys.lastReviewRequestAppVersion.rawValue)
  }
}

