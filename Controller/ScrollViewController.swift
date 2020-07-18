//
//  ScrollViewController.swift
//  Tint
//
//  Created by debavlad on 11.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

enum ScrollDirection {
  case right
  case left
}

final class ScrollViewController: UIViewController {
	private lazy var scrollView: UIScrollView = {
		let scrollView = UIScrollView(frame: view.frame)
		scrollView.isScrollEnabled = false
		return scrollView
	}()
  private let buttonsStackView = UIStackView()
  private let controllers = [
    CameraController(),
    LibraryController(),
    HistoryController()
  ]
  private let icons = [
    "camera.fill",
    "photo.fill",
    "folder.fill"
  ]
	private var currentPage = 0
  private let bottomView = UIView()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.clipsToBounds = true
		setupPages()
		setupBottom()
		setupButtons()
	}

	private func setupPages() {
		view.addSubview(scrollView)
    for i in 0..<controllers.count {
      controllers[i].view.frame.origin.x = view.frame.width * CGFloat(i)
      controllers[i].view.tag = i

      scrollView.addSubview(controllers[i].view)
      addChild(controllers[i])
      controllers[i].didMove(toParent: self)

      let button = BarButton(icons[i])
      button.set(size: 22, weight: .medium)
      button.tag = i
      button.addTarget(self, action: #selector(handleTap(on:)), for: .touchDown)
      buttonsStackView.addArrangedSubview(button)
    }
    scrollView.contentSize.width = scrollView.frame.width * CGFloat(controllers.count)
	}

  private func setupBottom() {
    bottomView.backgroundColor = .white
    bottomView.layer.cornerRadius = 25
    bottomView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(bottomView)
    NSLayoutConstraint.activate([
      bottomView.widthAnchor.constraint(equalTo: view.widthAnchor),
      bottomView.heightAnchor.constraint(equalToConstant: 65),
      bottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 15),
      bottomView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ])

    let backView = UIView()
    backView.backgroundColor = .white
    backView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(backView)
    NSLayoutConstraint.activate([
      backView.widthAnchor.constraint(equalTo: view.widthAnchor),
      backView.topAnchor.constraint(equalTo: bottomView.centerYAnchor),
      backView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      backView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ])
    view.bringSubviewToFront(bottomView)
  }

	private func setupButtons() {
		buttonsStackView.spacing = 2
		buttonsStackView.arrangedSubviews.first?.tintColor = .darkGray
		bottomView.addSubview(buttonsStackView)
		buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			buttonsStackView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -20),
			buttonsStackView.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor)
		])
	}

  @objc private func handleTap(on sender: UIButton) {
    guard sender.tag != currentPage else {
      return
    }
    buttonsStackView.arrangedSubviews[currentPage].tintColor = .lightGray
    buttonsStackView.arrangedSubviews[sender.tag].tintColor = .darkGray
    let direction: ScrollDirection = sender.tag >= currentPage ? .right : .left
    let offset = scrollView.contentOffset.x + (direction == .right ? view.frame.width : -view.frame.width)
    controllers[sender.tag].view.frame.origin.x = offset
    scrollView.bringSubviewToFront(controllers[sender.tag].view)

    scrollView.contentOffset.x = offset
    currentPage = sender.tag
  }

	override var prefersStatusBarHidden: Bool {
		true
	}
}
