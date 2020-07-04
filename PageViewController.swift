//
//  PageViewController.swift
//  Tint
//
//  Created by debavlad on 02.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

	lazy var orderedViewControllers: [UIViewController] = {
		return self.getViewControllers()
	}()
	let switchView = SwitchView()

	override func viewDidLoad() {
		super.viewDidLoad()
		dataSource = self
		if let firstViewController = orderedViewControllers.first {
			setViewControllers([firstViewController],
							   direction: .forward,
							   animated: true,
							   completion: nil)
		}

		switchView.cameraButton.addTarget(self, action: #selector(scrollToCamera), for: .touchDown)
		switchView.libraryButton.addTarget(self, action: #selector(scrollToLibrary), for: .touchDown)
		switchView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(switchView)
		NSLayoutConstraint.activate([
			switchView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			switchView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15)
		])
	}

	@objc private func scrollToCamera() {
		setViewControllers([orderedViewControllers.first!], direction: .reverse, animated: true, completion: nil)
	}

	@objc private func scrollToLibrary() {
		setViewControllers([orderedViewControllers.last!], direction: .forward, animated: true, completion: nil)
	}

	fileprivate func getViewControllers() -> [UIViewController] {
		let redVc = ViewController()
		redVc.view.backgroundColor = .systemRed
		let blueVc = LibraryController()
		blueVc.view.backgroundColor = .systemBlue
		return [redVc, blueVc]
	}

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else { return nil}
		let previousIndex = viewControllerIndex - 1
		guard previousIndex >= 0 else {
			return orderedViewControllers.last
		}
		guard orderedViewControllers.count > previousIndex else {
			return nil
		}
		return orderedViewControllers[previousIndex]
	}

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else { return nil}
		let nextIndex = viewControllerIndex + 1
		guard orderedViewControllers.count != nextIndex else {
			return orderedViewControllers.first
		}
		guard orderedViewControllers.count > nextIndex else {
			return nil
		}
		return orderedViewControllers[nextIndex]
	}
}
