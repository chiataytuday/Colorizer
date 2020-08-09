//
//  ScrollViewController.swift
//  Tint
//
//  Created by debavlad on 11.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

@objc protocol ScrollableViewDelegate {
  func scrollableViewWillAppear()
  func scrollableViewWillDisappear()
}

enum ScrollDirection {
  case right
  case left
}

/**
 
 */

final class ScrollViewController: UIViewController {
  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView(frame: view.frame)
    scrollView.isScrollEnabled = false
    return scrollView
  }()
  private let buttonsStackView = UIStackView()
  private var controllers: [UIViewController] = []
  private var icons: [String] = []
  private var currentPage = 0
  private let bottomView = UIView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.clipsToBounds = true
    setupControllers()
    setupPages()
    setupBottom()
    setupButtons()
  }

  private func setupControllers() {
    let libraryController = ImageController()
    let libraryIcon = "person.crop.square"
    controllers.append(libraryController)
    icons.append(libraryIcon)

    let cameraController = CameraController()
    let cameraIcon = "viewfinder"
    controllers.append(cameraController)
    icons.append(cameraIcon)

    let historyController = ArchiveController()
    let historyIcon = "archivebox"
    controllers.append(historyController)
    icons.append(historyIcon)

    cameraController.updateColorsArchive = historyController.synchronize
    libraryController.updateColorsArchive = historyController.synchronize
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
      button.set(size: 25, weight: .regular)
      button.tag = i
      button.addTarget(self, action: #selector(handleTap(on:)), for: .touchDown)
      buttonsStackView.addArrangedSubview(button)
    }
    scrollView.contentSize.width = scrollView.frame.width * CGFloat(controllers.count)
  }

  override func viewWillAppear(_ animated: Bool) {
    /* Pages change their order for some reason, so
     we reset current page's offset here */

    let offset = controllers[currentPage].view.frame.origin.x
    scrollView.contentOffset.x = offset
  }
  
  private func setupBottom() {
    bottomView.backgroundColor = .white
    bottomView.layer.cornerRadius = 30
    view.addSubview(bottomView)
    bottomView.translatesAutoresizingMaskIntoConstraints = false
    let bottomMargin: CGFloat = Device.shared.hasNotch ? 10 : 0
    NSLayoutConstraint.activate([
      bottomView.widthAnchor.constraint(equalTo: view.widthAnchor),
      bottomView.heightAnchor.constraint(equalToConstant: 65),
      bottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: bottomMargin),
      bottomView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ])
    (controllers[0] as? ImageController)?.bottomBarConstraint = bottomView.topAnchor
    
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
    buttonsStackView.distribution = .fillEqually
    buttonsStackView.arrangedSubviews.first?.tintColor = .black
    bottomView.addSubview(buttonsStackView)
    buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      buttonsStackView.widthAnchor.constraint(equalTo: bottomView.widthAnchor, multiplier: 0.8),
      buttonsStackView.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
      buttonsStackView.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor)
    ])
  }
  
  @objc private func handleTap(on sender: UIButton) {
    guard sender.tag != currentPage else {
      return
    }
    (controllers[sender.tag] as? CameraController)?.isCurrent = true
    (controllers[currentPage] as? ScrollableViewDelegate)?.scrollableViewWillDisappear()
    (controllers[sender.tag] as? ScrollableViewDelegate)?.scrollableViewWillAppear()

    UIViewPropertyAnimator(duration: 0.1, curve: .easeOut) {
      self.buttonsStackView.arrangedSubviews[self.currentPage].tintColor = .softGray
      self.buttonsStackView.arrangedSubviews[sender.tag].tintColor = .black
    }.startAnimation()

    let direction: ScrollDirection = sender.tag >= currentPage ? .right : .left
    let offset = scrollView.contentOffset.x + (direction == .right ? view.frame.width : -view.frame.width)
    controllers[sender.tag].view.frame.origin.x = offset
    scrollView.bringSubviewToFront(controllers[sender.tag].view)

    UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
      self.scrollView.contentOffset.x = offset
    })
    currentPage = sender.tag
  }
  
  override var prefersStatusBarHidden: Bool {
    true
  }
}

//MARK: - UIColor
extension UIColor {
  static let softGray = UIColor(white: 0.775, alpha: 1)
}
