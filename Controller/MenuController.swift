//
//  MenuController.swift
//  Tint
//
//  Created by debavlad on 08.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class MenuController: UITabBarController {

	override func viewDidLoad() {
		super.viewDidLoad()
		tabBar.isTranslucent = false
		tabBar.barTintColor = UIColor(white: 0.95, alpha: 1)
		tabBar.tintColor = .darkGray
		setupTabBar()
	}

	fileprivate func setupTabBar() {
		let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
		let randomController = UINavigationController(rootViewController: UIViewController())
		randomController.setNavigationBarHidden(true, animated: false)
		randomController.tabBarItem.image = UIImage(systemName: "icloud", withConfiguration: config)
		randomController.tabBarItem.selectedImage = UIImage(systemName: "icloud.fill", withConfiguration: config)

		let cameraController = UINavigationController(rootViewController: ViewController())
		cameraController.setNavigationBarHidden(true, animated: false)
		cameraController.tabBarItem.image = UIImage(systemName: "camera", withConfiguration: config)
		cameraController.tabBarItem.selectedImage = UIImage(systemName: "camera.fill", withConfiguration: config)

		let libraryController = UINavigationController(rootViewController: LibraryController())
		libraryController.setNavigationBarHidden(true, animated: false)
		libraryController.tabBarItem.image = UIImage(systemName: "photo", withConfiguration: config)
		libraryController.tabBarItem.selectedImage = UIImage(systemName: "photo.fill", withConfiguration: config)

		let foldersController = UINavigationController(rootViewController: UIViewController())
		foldersController.setNavigationBarHidden(true, animated: false)
		foldersController.tabBarItem.image = UIImage(systemName: "folder", withConfiguration: config)
		foldersController.tabBarItem.selectedImage = UIImage(systemName: "folder.fill", withConfiguration: config)

		viewControllers = [randomController, libraryController, cameraController, foldersController]
	}
}

extension UIImage {
    class func colorForNavBar(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()

		context!.setFillColor(color.cgColor)
		context!.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }
}
