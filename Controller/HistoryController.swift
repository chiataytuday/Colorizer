//
//  HistoryController.swift
//  Tint
//
//  Created by debavlad on 14.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

protocol ColorCellDelegate {
  func presentColorController(with color: UIColor)
}

final class HistoryController: UIViewController {
  private let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 56, right: 0)
    layout.headerReferenceSize.height = 70
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
    collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    collectionView.backgroundColor = UIColor(white: 0.95, alpha: 1)
    collectionView.alwaysBounceVertical = true
    return collectionView
  }()
  private var colors = APIManager.shared.fetchColors()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(white: 0.95, alpha: 1)
    setupCollectionView()
  }

  func reloadCollectionView() {
    colors = APIManager.shared.fetchColors()
    collectionView.reloadData()
  }

  private func setupCollectionView() {
    collectionView.delegate = self
    collectionView.dataSource = self
    view.addSubview(collectionView)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])
  }
}

// MARK: - UICollectionViewDelegate
extension HistoryController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 1
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 1
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let colorController = ColorController()
    let color = colors[indexPath.item]
    colorController.configure(with: color)
    colorController.updateColorsArchive = reloadCollectionView
    colorController.modalPresentationStyle = .fullScreen
    present(colorController, animated: true)
  }

  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath)
    return header
  }
}

// MARK: - UICollectionViewDataSource
extension HistoryController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return colors.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
    let color = colors[indexPath.item]
    cell.backgroundColor = color
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HistoryController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let size = (collectionView.frame.width - 4)/5
    return CGSize(width: size, height: size)
  }
}

extension HistoryController: ColorCellDelegate {
  func presentColorController(with color: UIColor) {
    let colorController = ColorController()
    colorController.configure(with: color)
    colorController.modalPresentationStyle = .fullScreen
    present(colorController, animated: true)
  }
}
