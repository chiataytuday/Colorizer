//
//  ScrollViewController.swift
//  Tint
//
//  Created by debavlad on 11.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

protocol ScrollViewDelegate {
	func setPageButtons(_ views: [UIView], with tag: Int)
}

class ScrollViewController: UIViewController, ScrollViewDelegate {
	private lazy var scrollView: UIScrollView = {
		let scrollView = UIScrollView(frame: view.frame)
		scrollView.isScrollEnabled = false
		return scrollView
	}()
	private var buttonsStackView = UIStackView()
	private var pages = [UIView]()
	private var currentPage = 0
	private var dict = [Int : UIStackView]()
	private var images: [String] = [
		"camera.fill", "photo.fill", "folder.fill"
	]

	override func viewDidLoad() {
		super.viewDidLoad()
		setupPages()
		setupBottom()
		setupButtons()
	}

	func setPageButtons(_ views: [UIView], with tag: Int) {
		let stackView = UIStackView(arrangedSubviews: views)
		bottomView.addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			stackView.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
			stackView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 15)
		])

		dict[tag] = stackView
		guard tag != currentPage else { return }
		stackView.arrangedSubviews.forEach { view in
			view.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
			view.alpha = 0
		}
	}

	fileprivate func setupPages() {
		view.addSubview(scrollView)

		let cameraController = CameraController()
		cameraController.delegate = self
		cameraController.view.backgroundColor = UIColor(white: 0.95, alpha: 1)
		cameraController.view.tag = 0
		addPage(cameraController)
		appendButton()

		let libraryController = LibraryController()
		libraryController.delegate = self
		libraryController.view.frame.origin.x = view.frame.width
		libraryController.view.tag = 1
		addPage(libraryController)
		appendButton()

		let historyController = HistoryController()
		cameraController.updateColors = historyController.reloadCollectionView
		historyController.view.frame.origin.x = view.frame.width * 2
		historyController.view.tag = 2
		addPage(historyController)
		appendButton()
	}

	fileprivate func setupButtons() {
		buttonsStackView.spacing = 2
		buttonsStackView.arrangedSubviews.first?.tintColor = .darkGray
		bottomView.addSubview(buttonsStackView)
		buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			buttonsStackView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -20),
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

	fileprivate func addPage(_ viewController: UIViewController) {
		scrollView.addSubview(viewController.view)
		addChild(viewController)
		viewController.didMove(toParent: self)
		pages.append(viewController.view)
		scrollView.contentSize.width = scrollView.frame.width * CGFloat(pages.count)
	}

	fileprivate func appendButton() {
		let index = pages.count - 1
		let pageButton = BarButton(images[index])
		pageButton.isAnimatable = true
		pageButton.set(size: 22, weight: .medium)
		pageButton.tag = index
		pageButton.addTarget(self, action: #selector(animateScroll(sender:)), for: .touchDown)
		buttonsStackView.addArrangedSubview(pageButton)
	}

	enum Direction {
		case right
		case left
	}

	@objc private func animateScroll(sender: UIButton) {
		guard sender.tag != currentPage else { return }

		dict[currentPage]?.arrangedSubviews.forEach { view in
			UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseOut], animations: {
				view.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
				view.isHidden = true
				view.alpha = 0
			})
		}
		dict[sender.tag]?.arrangedSubviews.forEach { view in
			UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseOut], animations: {
				view.transform = .identity
				view.isHidden = false
				view.alpha = 1
			})
		}
		UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseOut, .allowUserInteraction], animations: {
			self.buttonsStackView.arrangedSubviews[self.currentPage].tintColor = .lightGray
			self.buttonsStackView.arrangedSubviews[sender.tag].tintColor = .darkGray
		})

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
