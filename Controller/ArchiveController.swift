//
//  ArchiveController.swift
//  Tint
//
//  Created by debavlad on 14.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

final class ArchiveController: UIViewController {
  private let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 100, right: 0)
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
    collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    collectionView.backgroundColor = UIColor(white: 0.95, alpha: 1)
    collectionView.alwaysBounceVertical = true
    return collectionView
  }()
  private var colors = APIManager.shared.fetchColors()
  private var tipStackView: UIStackView!

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(white: 0.95, alpha: 1)
    setupCollectionView()
    layoutTipViews()

    if let colors = UserDefaults.standard.unarchiveColors(by: "colors") {
      APIManager.shared.set(colors: colors)
      updateColorsArchive()
    }
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

  private func layoutTipViews() {
    let tipImageView = UIImageView(image: UIImage(systemName: "bin.xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .light)))
    tipImageView.tintColor = .lightGray

    let tipLabel = UILabel()
    tipLabel.text = "Archive is empty"
    tipLabel.font = .systemFont(ofSize: 16.5, weight: .regular)
    tipLabel.textColor = .lightGray

    tipStackView = UIStackView(arrangedSubviews: [tipImageView, tipLabel])
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
}

// MARK: - ColorsArchiveUpdaing
extension ArchiveController: ColorsArchiveUpdating {
  func updateColorsArchive() {
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
    colorController.delegate = self
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
    cell.backgroundColor = colors[indexPath.item]
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
