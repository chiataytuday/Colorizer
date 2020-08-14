//
//  ArchiveController.swift
//  Tint
//
//  Created by debavlad on 14.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

protocol ColorCellDelegate {
  func presentColorController(with color: UIColor)
}

final class ArchiveController: UIViewController {
  private let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 18, left: 0, bottom: 100, right: 0)
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.register(ArchiveHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
    collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    collectionView.backgroundColor = UIColor(white: 0.95, alpha: 1)
    collectionView.alwaysBounceVertical = true
    return collectionView
  }()
  private var tipStackView: UIStackView = {
    let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
    let image = UIImage(systemName: "bin.xmark", withConfiguration: config)
    let imageView = UIImageView(image: image)
    imageView.tintColor = .lightGray

    let label = UILabel()
    label.text = "Archive is empty"
    label.font = UIFont.systemFont(ofSize: 17, weight: .light)
    label.textColor = .lightGray

    return UIStackView(arrangedSubviews: [imageView, label])
  }()
  private var colors = APIManager.shared.fetchColors()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(white: 0.95, alpha: 1)
    setupCollectionView()
    setupTipStackView()
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

  private func setupTipStackView() {
    tipStackView.axis = .vertical
    tipStackView.alignment = .center
    tipStackView.spacing = 7.5
    view.addSubview(tipStackView)
    tipStackView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tipStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      tipStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }

  func synchronize() {
    colors = APIManager.shared.fetchColors()
    tipStackView.isHidden = colors.count > 0
    collectionView.reloadData()
  }
}

// MARK: - UICollectionViewDelegate
extension ArchiveController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let color = colors[indexPath.item]
    let colorController = ColorController()
    colorController.configure(with: color)
    colorController.updateColorsArchive = synchronize
    colorController.modalPresentationStyle = .fullScreen
    present(colorController, animated: true)
  }

  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath)
    return header
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 1
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 1
  }
}

// MARK: - UICollectionViewDataSource
extension ArchiveController: UICollectionViewDataSource {
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
extension ArchiveController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let size = (collectionView.frame.width - 4)/5
    return CGSize(width: size, height: size)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    let height = colors.count > 0 ? 73.5 : 0
    return CGSize(width: 0, height: height)
  }
}

extension ArchiveController: ColorCellDelegate {
  func presentColorController(with color: UIColor) {
    let colorController = ColorController()
    colorController.configure(with: color)
    colorController.modalPresentationStyle = .fullScreen
    present(colorController, animated: true)
  }
}
