//
//  ColorController.swift
//  Tint
//
//  Created by debavlad on 05.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

protocol ColorsArchiveUpdating {
  func updateColorsArchive()
}

final class ColorController: UIViewController {
  private let saveButton: UIButton = {
    let button = RoundButton(size: CGSize(width: 47, height: 46))
    button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 25, weight: .light), forImageIn: .normal)
    button.setImage(UIImage(systemName: "suit.heart"), for: .normal)
    button.backgroundColor = .clear
    button.tag = 0
    return button
  }()
  private let backButton: UIButton = {
    let button = RoundButton(size: CGSize(width: 47, height: 46))
    button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 25, weight: .light), forImageIn: .normal)
    button.setImage(UIImage(systemName: "arrow.down"), for: .normal)
    button.backgroundColor = .clear
    return button
  }()
  private let stackView = UIStackView()
  var delegate: ColorsArchiveUpdating?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    transitioningDelegate = self
    setupButtons()
  }

  func configure(with color: UIColor) {
    view.backgroundColor = color
    backButton.tintColor = color.readable
    saveButton.tintColor = color.readable
    if APIManager.shared.contains(color: color) {
      saveButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
      saveButton.tag = 1
    }
    setupStackView()
  }

  private func setupButtons() {
    view.addSubview(backButton)
    backButton.addTarget(self, action: #selector(backToScroll), for: .touchUpInside)
    backButton.translatesAutoresizingMaskIntoConstraints = false
    let bottomMargin: CGFloat = Device.shared.hasNotch ? -10 : -30
    NSLayoutConstraint.activate([
      backButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
      backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: bottomMargin)
    ])

    view.addSubview(saveButton)
    saveButton.addTarget(self, action: #selector(likeButtonTapped(sender:)), for: .touchUpInside)
    saveButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      saveButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
      saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30)
    ])
  }

  private func setupStackView() {
    guard let color = view.backgroundColor else { return }
    stackView.axis = .vertical
    stackView.alignment = .leading
    stackView.spacing = 6

    _ = [
      Color("HEX", color.hex),
      Color("RGB", color.rgb),
      Color("HSB", color.hsb),
      Color("CMYK", color.cmyk)
    ].map {
      let dataView = ColorDataView(with: $0)
      dataView.set(color: color.readable)
      stackView.addArrangedSubview(dataView)
    }

    view.addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    stackView.transform = CGAffineTransform(translationX: 0, y: -400)
    saveButton.transform = CGAffineTransform(translationX: 0, y: -400)
    backButton.transform = CGAffineTransform(translationX: 0, y: -400)
    UIView.animate(withDuration: 0.65, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: [.curveEaseOut, .allowUserInteraction], animations: {
      self.stackView.transform = .identity
      self.saveButton.transform = .identity
      self.backButton.transform = .identity
    })
  }
  
  override var prefersStatusBarHidden: Bool {
    true
  }
}

//MARK: - Target actions
@objc extension ColorController {
  private func likeButtonTapped(sender: UIButton) {
    switch sender.tag {
      case 0:
        APIManager.shared.add(color: view.backgroundColor!)
        sender.tag = 1
        sender.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
      case 1:
        APIManager.shared.remove(color: view.backgroundColor!)
        sender.tag = 0
        sender.setImage(UIImage(systemName: "suit.heart"), for: .normal)
      default:
        break
    }
    UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.4)
    delegate?.updateColorsArchive()
  }

  private func backToScroll() {
    dismiss(animated: true)
    ReviewManager.requestReviewIfAppropriate()
  }
}

//MARK: - UIViewControllerTransitioningDelegate
extension ColorController: UIViewControllerTransitioningDelegate {
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return AnimationController(duration: 0.48, type: .present)
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return AnimationController(duration: 0.48, type: .dismiss)
  }
}

//MARK: - UIColor
extension UIColor {
  var readable: UIColor {
    var white: CGFloat = 0
    getWhite(&white, alpha: nil)
    let color = white > 0.65 ? UIColor.black.withAlphaComponent(0.4) :
      UIColor.white.withAlphaComponent(0.8)
    return color
  }

  var hex: String {
    guard let components = cgColor.components,
      components.count >= 3 else {
      return "#000000"
    }
    let values = components.map {
      lroundf(Float($0) * 255)
    }
    return String(format: "#%02lX%02lX%02lX", values[0], values[1], values[2])
  }

  var rgb: String {
    guard let components = cgColor.components, components.count >= 3 else {
      return "0 0 0"
    }
    let values = components.map {
      Int(($0 * 255).rounded())
    }
    return "\(values[0]) \(values[1]) \(values[2])"
  }

  var hsb: String {
    var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0
    getHue(&h, saturation: &s, brightness: &b, alpha: nil)
    let values = [h * 360, s * 100, b * 100].map {
      Int($0.rounded())
    }
    return "\(values[0]) \(values[1]) \(values[2])"
  }

  var cmyk: String {
    guard let components = cgColor.components, components.count >= 3,
      components[0] != 0, components[1] != 0, components[2] != 0 else {
      return "0 0 0 100"
    }
    var c = 1 - components[0], m = 1 - components[1], y = 1 - components[2]
    let minCMY = min(c, m, y)
    c = (c - minCMY)/(1 - minCMY)
    m = (m - minCMY)/(1 - minCMY)
    y = (y - minCMY)/(1 - minCMY)

    let values = [c, m, y, minCMY].map {
      Int(($0 * 100).rounded())
    }
    return "\(values[0]) \(values[1]) \(values[2]) \(values[3])"
  }
}
