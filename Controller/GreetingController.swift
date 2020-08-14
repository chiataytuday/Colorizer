//
//  GreetingController.swift
//  Tint
//
//  Created by debavlad on 14.08.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit
import AVFoundation

class GreetingController: UIViewController {
  private let welcomeLabel: UILabel = {
    let label = UILabel()
    label.text = "Welcome to Tint"
    label.font = UIFont.systemFont(ofSize: 32, weight: .thin)
    label.textAlignment = .center
    label.textColor = .black
    return label
  }()
  private let descriptionLabel: UILabel = {
    let label = UILabel()
    label.text = "Allow camera usage so you can pick\ncolors from real world"
    label.font = UIFont.systemFont(ofSize: 13.5, weight: .regular)
    label.textAlignment = .center
    label.textColor = .lightGray
    label.numberOfLines = 2
    return label
  }()
  private let allowButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setTitle("Access camera", for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 17.5, weight: .light)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = .darkGray
    button.heightAnchor.constraint(equalToConstant: 50).isActive = true
    button.layer.cornerRadius = 25
    return button
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setupStackView()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
//    welcomeLabel.transform = CGAffineTransform(translationX: 0, y: -1200)
//    descriptionLabel.transform = CGAffineTransform(translationX: 0, y: -1200)
//    allowButton.transform = CGAffineTransform(translationX: 0, y: -1200)
//    usageLabel.transform = CGAffineTransform(translationX: 0, y: -1200)
//    UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.allowUserInteraction], animations: {
//      self.welcomeLabel.transform = .identity
//      self.descriptionLabel.transform = .identity
//      self.allowButton.transform = .identity
//      self.usageLabel.transform = .identity
//    })
  }

  private func setupStackView() {
    allowButton.addTarget(self, action: #selector(requestCameraAccess(sender:)), for: .touchDown)

    view.addSubview(welcomeLabel)
    welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      welcomeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])

    let stackView = UIStackView(arrangedSubviews: [allowButton, descriptionLabel])
    stackView.axis = .vertical
    stackView.spacing = 14
    view.addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
      stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
      stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
    ])
  }

  @objc private func requestCameraAccess(sender: UIButton) {
    AVCaptureDevice.requestAccess(for: .video) { _ in
      Device.shared.refreshCameraStatus()

      DispatchQueue.main.async {
        let scrollViewController = ScrollViewController()
        scrollViewController.modalPresentationStyle = .fullScreen
        self.present(scrollViewController, animated: true)
      }
    }
  }

  override var prefersStatusBarHidden: Bool {
    true
  }
}
