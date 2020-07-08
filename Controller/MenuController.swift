//
//  MenuController.swift
//  Tint
//
//  Created by debavlad on 08.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

class MenuController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = UIColor(white: 0.95, alpha: 1)
		setupStackView()
	}

	fileprivate func setupStackView() {
		let cameraButton = MenuButton(text: "Camera", imageName: "camera.fill")
		cameraButton.delegate = openCameraController
		let libraryButton = MenuButton(text: "Library", imageName: "photo.fill")
		libraryButton.delegate = openLibraryController
		let folderButton = MenuButton(text: "Collections", imageName: "folder.fill")
		let stackView = UIStackView(arrangedSubviews: [cameraButton, libraryButton, folderButton])
		stackView.axis = .vertical

		view.addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
			stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30)
		])
	}

	fileprivate func openCameraController() {
		let cameraController = ViewController()
		cameraController.modalPresentationStyle = .fullScreen
		present(cameraController, animated: true)
	}

	fileprivate func openLibraryController() {
		let libraryController = LibraryController()
		libraryController.modalPresentationStyle = .fullScreen
		present(libraryController, animated: true)
	}

	override var prefersStatusBarHidden: Bool {
		true
	}
}
