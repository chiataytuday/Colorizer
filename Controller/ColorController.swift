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
    button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 18, weight: .regular), forImageIn: .normal)
    button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
    button.imageEdgeInsets.top =  2.5
    return button
  }()
  private let saveButton: UIButton = {
    let button = RoundButton(size: CGSize(width: 185, height: 46))
    button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 18, weight: .regular), forImageIn: .normal)
    button.setImage(UIImage(systemName: "plus"), for: .normal)
    button.setTitle("Add to archive", for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
  button.imageEdgeInsets.top = 1
    button.imageEdgeInsets.left = -8
    button.titleEdgeInsets.left = 8
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
  
  private func setupStackView() {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.alignment = .leading
    stackView.axis = .vertical
    
    guard let data = colorData else { return }
    for color in data {
      let rowView = ColorRowView(title: color.spaceName, value: color.value)
      stackView.addArrangedSubview(rowView)
      rowViews.append(rowView)
    }
    
    view.addSubview(stackView)
    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17.5),
      stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -22.5)
    ])
  }
  
  func set(color: UIColor) {
    view.backgroundColor = color
    backButton.tintColor = color
    colorData = [
      Color(spaceName: "HEX", value: color.hex),
      Color(spaceName: "RGB", value: color.rgb),
      Color(spaceName: "HSB", value: color.hsb),
      Color(spaceName: "CMYK", value: color.cmyk)
    ]
    
    backButton.backgroundColor = color.readable
    for rowView in rowViews {
      rowView.set(color: color.readable)
    }

    saveButton.tintColor = color
    saveButton.backgroundColor = color.readable
    saveButton.setTitleColor(color, for: .normal)

    setupInfoButtons(colorData!)
  }

  func setupInfoButtons(_ data: [Color]) {
    let stackView = UIStackView()
    stackView.distribution = .fillEqually
    stackView.alignment = .center
    stackView.spacing = 8

    for i in 0..<data.count {
      let button = UIButton(type: .custom)
      button.layer.cornerRadius = 17.5
      button.setTitle(data[i].spaceName, for: .normal)
      button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
      button.setTitleColor(saveButton.backgroundColor, for: .normal)
      button.heightAnchor.constraint(equalToConstant: 35).isActive = true
      stackView.addArrangedSubview(button)
    }
    stackView.arrangedSubviews.first?.backgroundColor = saveButton.backgroundColor?.withAlphaComponent(0.6)
    (stackView.arrangedSubviews.first as? UIButton)?.setTitleColor(saveButton.tintColor, for: .normal)

    view.addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      stackView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -80),
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
      stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
    ])


    let copyButton = UIButton(type: .custom)
    copyButton.setTitle("255 60 23", for: .normal)
    let copyImage = UIImage(systemName: "doc.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .regular))
    copyButton.setImage(copyImage?.withHorizontallyFlippedOrientation(), for: .normal)
    copyButton.titleLabel?.font = UIFont.monospacedFont(ofSize: 22, weight: .light)
    copyButton.imageEdgeInsets.left = -14
    copyButton.titleEdgeInsets.left = 14
    copyButton.layer.cornerRadius = 25
    copyButton.backgroundColor = saveButton.backgroundColor?.withAlphaComponent(0.6)
    copyButton.setTitleColor(saveButton.tintColor, for: .normal)
    copyButton.tintColor = saveButton.tintColor
    view.addSubview(copyButton)
    copyButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      copyButton.heightAnchor.constraint(equalToConstant: 50),
      copyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
      copyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
      copyButton.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -10)
    ])
  }
  
  @objc private func backToCamera() {
    dismiss(animated: true, completion: nil)
  }

  @objc private func addToLibrary() {
    APIManager.shared.addColor(saveButton.tintColor)
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
