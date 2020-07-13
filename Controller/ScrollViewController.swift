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
		return scrollView
	}()
	private var buttonsStackView = UIStackView()
	private var pages = [UIView]()
	private var currentPage = 0

	override func viewDidLoad() {
		super.viewDidLoad()
		setupPages()
		setupBottom()
		setupButtons()
	}

	fileprivate func setupPages() {
		view.addSubview(scrollView)

		let cameraController = CameraController()
		cameraController.bottomView = bottomView
		cameraController.view.backgroundColor = UIColor(white: 0.95, alpha: 1)
		cameraController.view.tag = 0
		addPage(cameraController)
		appendButton()

		let libraryController = LibraryController()
		libraryController.view.frame.origin.x = view.frame.width
		libraryController.view.tag = 2
		addPage(libraryController)
		appendButton()
	}

	fileprivate func setupButtons() {
		buttonsStackView.spacing = 10
		bottomView.addSubview(buttonsStackView)
		buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			buttonsStackView.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
			buttonsStackView.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor)
		])
	}

	let bottomView = UIView()

	fileprivate func setupBottom() {
		bottomView.backgroundColor = .white
		bottomView.layer.cornerRadius = 25
		bottomView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(bottomView)
		NSLayoutConstraint.activate([
			bottomView.widthAnchor.constraint(equalTo: view.widthAnchor),
			bottomView.heightAnchor.constraint(equalToConstant: 65),
			bottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
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

	fileprivate func addPage(_ viewController: UIViewController) {
		scrollView.addSubview(viewController.view)
		addChild(viewController)
		viewController.didMove(toParent: self)
		pages.append(viewController.view)
		scrollView.contentSize.width = scrollView.frame.width * CGFloat(pages.count)
	}

	fileprivate func appendButton() {
		let button = UIButton(type: .custom)
		button.backgroundColor = UIColor(white: 0.8, alpha: 1)
		button.tag = pages.count - 1
		button.layer.cornerRadius = 17.5
		button.addTarget(self, action: #selector(animateScroll(sender:)), for: .touchDown)
		button.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			button.widthAnchor.constraint(equalToConstant: 45),
			button.heightAnchor.constraint(equalToConstant: 45)
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

extension UIView {
    func rounded() {
        let maskPath1 = UIBezierPath(roundedRect: bounds,
            byRoundingCorners: [.topLeft , .topRight],
            cornerRadii: CGSize(width: 25, height: 25))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
}
