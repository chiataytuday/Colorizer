//
//  ColorController.swift
//  Tint
//
//  Created by debavlad on 05.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

final class ColorController: UIViewController {
  var updateColorsArchive: (() -> Void)?

  private var colorData: [Color]?
  private let backButton: UIButton = {
    let button = RoundButton(size: CGSize(width: 47, height: 46))
    button.backgroundColor = .clear
    button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 25, weight: .light), forImageIn: .normal)
    button.setImage(UIImage(systemName: "arrow.down"), for: .normal)
    return button
  }()
  private let saveButton: UIButton = {
    let button = RoundButton(size: CGSize(width: 47, height: 46))
    button.backgroundColor = .clear
    button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 25, weight: .light), forImageIn: .normal)
    button.setImage(UIImage(systemName: "suit.heart"), for: .normal)
    button.tag = 0
    return button
  }()
  private var rowViews = [ColorRowView]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    transitioningDelegate = self
    setupBackButton()
  }
  
  private func setupBackButton() {
    view.addSubview(backButton)
    backButton.addTarget(self, action: #selector(backToCamera), for: .touchUpInside)
    backButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      backButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
      backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30)
    ])

    view.addSubview(saveButton)
    saveButton.addTarget(self, action: #selector(addToLibrary), for: .touchUpInside)
    saveButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      saveButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
      saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30)
    ])
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    stackView.transform = CGAffineTransform(translationX: 0, y: -500)
    saveButton.transform = CGAffineTransform(translationX: 0, y: -500)
    backButton.transform = CGAffineTransform(translationX: 0, y: -500)
    UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: [.curveEaseOut, .allowUserInteraction], animations: {
      self.stackView.transform = .identity
      self.saveButton.transform = .identity
      self.backButton.transform = .identity
    })
  }

  var stackView: UIStackView!
  
  private func setupStackView() {
    stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.alignment = .leading
    stackView.axis = .vertical
    stackView.spacing = 4
    
    guard let data = colorData else { return }
    for color in data {
      let rowView = ColorRowView(title: color.spaceName, value: color.value)
      stackView.addArrangedSubview(rowView)
      rowViews.append(rowView)
    }
    
    view.addSubview(stackView)
    NSLayoutConstraint.activate([
      stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }
  
  func set(color: UIColor) {
    view.backgroundColor = color
    backButton.tintColor = color.readable
    colorData = [
      Color(spaceName: "HEX", value: color.hex),
      Color(spaceName: "RGB", value: color.rgb),
      Color(spaceName: "HSB", value: color.hsb),
      Color(spaceName: "CMYK", value: color.cmyk)
    ]
    setupStackView()

    for rowView in rowViews {
      rowView.set(color: color.readable)
    }

    saveButton.tintColor = color.readable
    saveButton.setTitleColor(color, for: .normal)
  }
  
  @objc private func backToCamera() {
    dismiss(animated: true, completion: nil)
  }

  @objc private func addToLibrary() {
    guard saveButton.tag != 1 else {
      return
    }
    APIManager.shared.addColor(view.backgroundColor!)
    saveButton.tag = 1
    UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.3)
    saveButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
    updateColorsArchive?()
  }
  
  override var prefersStatusBarHidden: Bool {
    true
  }
}

extension ColorController: UIViewControllerTransitioningDelegate {
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return AnimationController(duration: 0.45, type: .present, direction: .vertical)
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return AnimationController(duration: 0.45, type: .dismiss, direction: .vertical)
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
}
