//
//  ColorController.swift
//  Tint
//
//  Created by debavlad on 05.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

final class ColorController: UIViewController {
  private let saveButton: UIButton = {
    let button = RoundButton(size: CGSize(width: 47, height: 46))
    button.backgroundColor = .clear
    button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 25, weight: .light), forImageIn: .normal)
    button.setImage(UIImage(systemName: "suit.heart"), for: .normal)
    button.tag = 0
    return button
  }()
  private let backButton: UIButton = {
    let button = RoundButton(size: CGSize(width: 47, height: 46))
    button.backgroundColor = .clear
    button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 25, weight: .light), forImageIn: .normal)
    button.setImage(UIImage(systemName: "arrow.down"), for: .normal)
    return button
  }()
  private var stackView = UIStackView()
  private var rowViews = [CopyableDataView]()
  var updateColorsArchive: (() -> Void)?
  private var colorData: [Color]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    transitioningDelegate = self
    setupButtons()
  }

  private func setupButtons() {
    view.addSubview(backButton)
    backButton.addTarget(self, action: #selector(backToCamera), for: .touchUpInside)
    backButton.translatesAutoresizingMaskIntoConstraints = false
    let bottomMargin: CGFloat = Device.shared.hasNotch ? -10 : -30
    NSLayoutConstraint.activate([
      backButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
      backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: bottomMargin)
    ])

    view.addSubview(saveButton)
    saveButton.addTarget(self, action: #selector(saveButtonTapped(sender:)), for: .touchUpInside)
    saveButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      saveButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
      saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30)
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
    
    ReviewManager.requestReviewIfAppropriate()
  }
  
  private func setupStackView() {
    stackView = UIStackView()
    stackView.alignment = .leading
    stackView.axis = .vertical
    stackView.spacing = 4
    
    guard let data = colorData else { return }
    for color in data {
      let rowView = CopyableDataView(title: color.spaceName, value: color.value)
      stackView.addArrangedSubview(rowView)
      rowViews.append(rowView)
    }
    
    view.addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }

  func configure(with color: UIColor) {
    view.backgroundColor = color
    backButton.tintColor = color.readable
    saveButton.tintColor = color.readable
    if APIManager.shared.contains(color: color) {
      saveButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
      saveButton.tag = 1
    }

    colorData = [
      Color(spaceName: "HEX", value: color.hex),
      Color(spaceName: "RGB", value: color.rgb),
      Color(spaceName: "HSB", value: color.hsb),
      Color(spaceName: "CMYK", value: color.cmyk)
    ]
    setupStackView()
    for row in rowViews {
      row.set(color: color.readable)
    }
  }
  
  override var prefersStatusBarHidden: Bool {
    true
  }
}

//MARK: - Target actions
extension ColorController {
  @objc private func saveButtonTapped(sender: UIButton) {
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
    UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.4)
    updateColorsArchive?()
  }

  @objc private func backToCamera() {
    dismiss(animated: true, completion: nil)
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
    let readableColor: UIColor
    if white > 0.65 {
      readableColor = UIColor.black.withAlphaComponent(0.4)
    } else {
      readableColor = UIColor.white.withAlphaComponent(0.8)
    }
    return readableColor
  }
  var hex: String {
    guard let components = cgColor.components, components.count >= 3 else {
      return "#FFFFFF"
    }
    let r = Float(components[0])
    let g = Float(components[1])
    let b = Float(components[2])
    return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
  }
  var rgb: String {
    let values: (r: CGFloat, g: CGFloat, b: CGFloat) = (
      (cgColor.components![0] * 255).rounded(),
      (cgColor.components![1] * 255).rounded(),
      (cgColor.components![2] * 255).rounded()
    )
    return "\(Int(values.r)) \(Int(values.g)) \(Int(values.b))"
  }
  var hsb: String {
    var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    getHue(&h, saturation: &s, brightness: &b, alpha: &a)
    let rounded: (h: CGFloat, s: CGFloat, b: CGFloat) = (
      (h*360).rounded(), (s*100).rounded(), (b*100).rounded()
    )
    return "\(Int(rounded.h)) \(Int(rounded.s)) \(Int(rounded.b))"
  }
  var cmyk: String {
    let r = cgColor.components![0]
    let g = cgColor.components![1]
    let b = cgColor.components![2]
    guard r != 0 && g != 0 && b != 0 else {
      return "0 0 0 100"
    }

    var c = 1 - r, m = 1 - g, y = 1 - b
    let minCMY = min(c, m, y)
    c = (c - minCMY) / (1 - minCMY)
    m = (m - minCMY) / (1 - minCMY)
    y = (y - minCMY) / (1 - minCMY)

    let rounded: (c: CGFloat, m: CGFloat, y: CGFloat, k: CGFloat) = (
      (c*100).rounded(), (m*100).rounded(), (y*100).rounded(), (minCMY*100).rounded()
    )
    return "\(Int(rounded.c)) \(Int(rounded.m)) \(Int(rounded.y)) \(Int(rounded.k))"
  }
}
