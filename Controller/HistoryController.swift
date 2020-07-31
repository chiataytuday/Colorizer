//
//  HistoryController.swift
//  Tint
//
//  Created by debavlad on 14.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

final class HistoryController: UIViewController {
  private let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 25, right: 0)
    layout.headerReferenceSize.height = 70
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
    collectionView.register(ColorCell.self, forCellWithReuseIdentifier: "Cell")
    collectionView.backgroundColor = UIColor(white: 0.95, alpha: 1)
    collectionView.alwaysBounceVertical = true
    return collectionView
  }()

  private let colors = APIManager.shared.fetchColors()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(white: 0.95, alpha: 1)
    setupCollectionView()
  }

  func reloadCollectionView() {
    collectionView.reloadData()
  }

  private func setupCollectionView() {
    collectionView.delegate = self
    collectionView.dataSource = self
    view.addSubview(collectionView)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ColorCell
    let color = colors[indexPath.item]
    cell.configure(with: color)
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
