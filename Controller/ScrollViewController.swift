//
//  ScrollViewController.swift
//  Tint
//
//  Created by debavlad on 11.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class ScrollViewController: UIViewController {
	private lazy var scrollView: UIScrollView = {
		let scrollView = UIScrollView(frame: view.frame)
		scrollView.isScrollEnabled = false
		scrollView.backgroundColor = .systemRed
		return scrollView
	}()
	private var buttonsStackView = UIStackView()
	private var pages = [UIView]()
	private var currentPage = 0

	override func viewDidLoad() {
		super.viewDidLoad()
		setupPages()
		setupButtons()
	}

	fileprivate func setupPages() {
		view.addSubview(scrollView)

		let cameraController = ViewController()
		cameraController.view.tag = 0
		addPage(cameraController)
		appendButton()

		let libraryController = LibraryController()
		libraryController.view.frame.origin.x = cameraController.view.frame.width
		libraryController.view.tag = 1
		addPage(libraryController)
		appendButton()
	}

	fileprivate func setupButtons() {
		buttonsStackView.spacing = 10
		view.addSubview(buttonsStackView)
		buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			buttonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
		])
	}

	fileprivate func addPage(_ viewController: UIViewController) {
		scrollView.addSubview(viewController.view)
		addChild(viewController)
		viewController.didMove(toParent: self)
		pages.append(viewController.view)
		scrollView.contentSize.width = scrollView.frame.width * CGFloat(pages.count)
	}

	fileprivate func appendButton() {
		let button = UIButton(type: .custom)
		button.backgroundColor = .red
		button.tag = pages.count - 1
		button.addTarget(self, action: #selector(animateScroll(sender:)), for: .touchDown)
		button.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			button.widthAnchor.constraint(equalToConstant: 50),
			button.heightAnchor.constraint(equalToConstant: 50)
		])
		buttonsStackView.addArrangedSubview(button)
	}

	enum Direction {
		case right
		case left
	}

	@objc private func animateScroll(sender: UIButton) {
		guard sender.tag != currentPage else { return }
		let direction: Direction = sender.tag >= currentPage ? .right : .left
		let newOffset = scrollView.contentOffset.x + (direction == .right ?
			view.frame.width : -view.frame.width)
		pages[sender.tag].frame.origin.x = newOffset
		scrollView.bringSubviewToFront(pages[sender.tag])

		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
			self.scrollView.contentOffset.x = newOffset
		})
		currentPage = sender.tag
	}

	override var prefersStatusBarHidden: Bool {
		true
	}
}
