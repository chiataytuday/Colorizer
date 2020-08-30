//
//  ScrollViewController.swift
//  Tint
//
//  Created by debavlad on 11.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

enum ScrollDirection {
  case left, right
}

final class RootViewController: UIViewController {
  private lazy var containerScrollView: UIScrollView = {
    let scrollView = UIScrollView(frame: view.frame)
    scrollView.isScrollEnabled = false
    return scrollView
  }()
  private let buttonsStackView = UIStackView()
  private let barView = UIView()
  private var pages: [Page] = []
  private var currentPage = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.clipsToBounds = true
    transitioningDelegate = self
    setupPages()
    layoutPages()
    setupNavigationBar()
    layoutBarButtons()
  }

  private func setupPages() {
    let archiveController = ArchiveController()
    let imageController = ImageController()
    imageController.delegate = archiveController
    pages.append(contentsOf: [
      Page(imageController, "person.crop.square"),
      Page(archiveController, "archivebox")
    ])

    guard Device.shared.cameraStatus == .authorized else { return }
    let cameraController = CameraController()
    cameraController.delegate = archiveController
    pages.insert(Page(cameraController, "viewfinder"), at: 1)
  }

  private func layoutPages() {
    view.addSubview(containerScrollView)
    var index = 0
    for page in pages {
      page.controller.view.frame.origin.x = view.frame.width * CGFloat(index)
      page.controller.view.tag = index

      // Do we need next 3 lines?
      containerScrollView.addSubview(page.controller.view)
      addChild(page.controller)
      page.controller.didMove(toParent: self)

      let button = BarButton(page.barImageName)
      button.set(size: 23, weight: .light)
      button.tag = index
      button.addTarget(self, action: #selector(navigate(to:)), for: .touchDown)
      buttonsStackView.addArrangedSubview(button)
      index += 1
    }
    containerScrollView.contentSize.width = view.frame.width * CGFloat(pages.count)
  }

  private func setupNavigationBar() {
    barView.backgroundColor = .white
    barView.layer.cornerRadius = 30
    barView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    barView.clipsToBounds = true
    view.addSubview(barView)

    let bottomInset = additionalSafeAreaInsets.bottom
    let barHeight = 65 + bottomInset - (bottomInset > 0 ? 10 : 0)
    barView.frame.size = CGSize(width: view.frame.width, height: barHeight)
    barView.frame.origin.y = view.frame.height - barHeight
    barView.center.x = view.center.x
  }

  private func layoutBarButtons() {
    buttonsStackView.distribution = .fillEqually
    buttonsStackView.arrangedSubviews.first?.tintColor = .black
    buttonsStackView.frame.size = CGSize(width: view.frame.width * 0.8, height: 65)
    buttonsStackView.center.x = barView.center.x
    buttonsStackView.center.y = barView.center.y - 10
    view.addSubview(buttonsStackView)
  }

  @objc private func navigate(to sender: UIButton) {
    guard sender.tag != currentPage else { return }
    scrolled(from: currentPage, to: sender.tag)

    let direction: ScrollDirection = sender.tag >= currentPage ? .right : .left
    let offset = containerScrollView.contentOffset.x +
      (direction == .right ? view.frame.width : -view.frame.width)
    pages[sender.tag].controller.view.frame.origin.x = offset
    containerScrollView.bringSubviewToFront(pages[sender.tag].controller.view)

    UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
      self.containerScrollView.contentOffset.x = offset
    })
    currentPage = sender.tag
  }

  private func scrolled(from: Int, to: Int) {
    pages[from].controller.willScrollAway()
    pages[to].controller.willScrollTo()
    UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
      self.buttonsStackView.arrangedSubviews[from].tintColor = .softGray
      self.buttonsStackView.arrangedSubviews[to].tintColor = .black
    })
  }

  override func viewWillAppear(_ animated: Bool) {
    /* Pages change their order for some reason, so
     we reset current page's offset here */
    let offset = pages[currentPage].controller.view.frame.origin.x
    containerScrollView.contentOffset.x = offset
  }

  override var prefersStatusBarHidden: Bool {
    true
  }
}

//MARK: - UIViewControllerTransitioningDelegate
extension RootViewController: UIViewControllerTransitioningDelegate {
  func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController,
    source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return AnimationController(duration: 0.65, type: .present)
  }
}

//MARK: - UIColor
extension UIColor {
  static let softGray = UIColor(white: 0.775, alpha: 1)
}
