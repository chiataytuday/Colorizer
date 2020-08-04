//
//  LibraryController.swift
//  Tint
//
//  Created by debavlad on 01.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

final class LibraryController: UIViewController {
  var updateColorsArchive: (() -> Void)?

  private var tipStackView: UIStackView!
  private let scrollView = UIScrollView()
  private var colorPickerView: ColorPicker!
  private var colorInfoView = ColorInfoView()
  private let doubleTapGesture = UITapGestureRecognizer()
  private var photoImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  private let imagePicker = UIImagePickerController()
  private let pickButton: UIButton = {
    let button = RoundButton(size: CGSize(width: 56, height: 55))
    button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .regular), forImageIn: .normal)
    button.setImage(UIImage(systemName: "photo"), for: .normal)
    button.tintColor = .softGray
    button.isHidden = true
    return button
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(white: 0.95, alpha: 1)
    transitioningDelegate = self
    if let colors = UserDefaults.standard.getColors(key: "colors") {
      APIManager.shared.colors = colors
      updateColorsArchive?()
    }

    setupTipViews()
    setupSubviews()
    setupDoubleTapRecognizer()
    setupImagePicker()
    setupBarButtons()
  }

  private func setupBarButtons() {
    pickButton.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
    pickButton.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(pickButton)
    NSLayoutConstraint.activate([
      pickButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -22.5),
      pickButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -77.5)
    ])
  }

  @objc private func openImagePicker() {
    present(imagePicker, animated: true)
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    openImagePicker()
  }

  fileprivate func setupTipViews() {
    let plusImageView: UIImageView = {
      let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
      let image = UIImage(systemName: "plus", withConfiguration: config)
      let imageView = UIImageView(image: image)
      imageView.contentMode = .center
      imageView.tintColor = .lightGray
      return imageView
    }()
    let tipLabel: UILabel = {
      let label = UILabel()
      label.text = "Tap anywhere to open a photo"
      label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
      label.textColor = .lightGray
      return label
    }()

    tipStackView = UIStackView(arrangedSubviews: [plusImageView, tipLabel])
    tipStackView.translatesAutoresizingMaskIntoConstraints = false
    tipStackView.axis = .vertical
    tipStackView.spacing = 10
    view.addSubview(tipStackView)
    NSLayoutConstraint.activate([
      tipStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      tipStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }

  fileprivate func setupSubviews() {
    scrollView.delegate = self
    scrollView.isUserInteractionEnabled = false
    scrollView.contentInsetAdjustmentBehavior = .never
    scrollView.delaysContentTouches = false
    scrollView.maximumZoomScale = 8
    view.addSubview(scrollView)
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])

    scrollView.addSubview(photoImageView)
    photoImageView.clipsToBounds = true
    photoImageView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      photoImageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      photoImageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      photoImageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      photoImageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      photoImageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
      photoImageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
    ])

    colorPickerView = ColorPicker(frame: CGRect(origin: .zero, size: CGSize(width: 35, height: 35)))
    colorPickerView.delegate = self
    colorPickerView.isHidden = true
    photoImageView.addSubview(colorPickerView)
    photoImageView.isUserInteractionEnabled = true
    colorPickerView.center = view.center

    colorInfoView = ColorInfoView()
    colorInfoView.delegate = self
    colorInfoView.isHidden = true
    colorInfoView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(colorInfoView)
    NSLayoutConstraint.activate([
      colorInfoView.widthAnchor.constraint(equalToConstant: 172),
      colorInfoView.heightAnchor.constraint(equalToConstant: 70),
      colorInfoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      colorInfoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15)
    ])
  }

  fileprivate func setupDoubleTapRecognizer() {
    doubleTapGesture.addTarget(self, action: #selector(handleDoubleTap(recognizer:)))
    doubleTapGesture.numberOfTapsRequired = 2
    doubleTapGesture.delaysTouchesBegan = false
    doubleTapGesture.delaysTouchesEnded = false
    scrollView.addGestureRecognizer(doubleTapGesture)
  }

  fileprivate func setupImagePicker() {
    imagePicker.delegate = self
    imagePicker.sourceType = .photoLibrary
    imagePicker.allowsEditing = false
  }

  @objc private func handleDoubleTap(recognizer: UITapGestureRecognizer) {
    if scrollView.zoomScale == 1 {
      let center = recognizer.location(in: recognizer.view)
      scrollView.zoom(to: zoomRectForScale(scale: 4, center:
        center), animated: true)
    } else {
      scrollView.setZoomScale(1, animated: true)
    }
  }

  private func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
    var zoomRect: CGRect = .zero
    zoomRect.size.height = photoImageView.frame.size.height / scale
    zoomRect.size.width  = photoImageView.frame.size.width  / scale

    let newCenter = scrollView.convert(center, from: photoImageView)
    zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
    zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
    return zoomRect
  }

  override var prefersStatusBarHidden: Bool {
    true
  }
}

extension LibraryController: UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return photoImageView
  }

  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    let scale = scrollView.zoomScale
    colorPickerView.transform = CGAffineTransform(scaleX: 1/scale, y: 1/scale)
    guard scale <= scrollView.maximumZoomScale else { return }
    if scale <= 1 {
      scrollView.contentInset = .zero
      return
    }
    guard let image = photoImageView.image else { return }
    let wRatio = photoImageView.frame.width / image.size.width
    let hRatio = photoImageView.frame.height / image.size.height
    let ratio = min(wRatio, hRatio)

    let newSize = CGSize(width: image.size.width * ratio,
                         height: image.size.height * ratio)
    let left = 0.5 * (newSize.width * scale > photoImageView.frame.width ? (newSize.width - photoImageView.frame.width) : (scrollView.frame.width - scrollView.contentSize.width))
    let top = 0.5 * (newSize.height * scale > photoImageView.frame.height ? (newSize.height - photoImageView.frame.height) : (scrollView.frame.height - scrollView.contentSize.height))

    scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
  }
}

extension LibraryController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    setImage(info[.originalImage] as? UIImage)
    calculateZoomScale()
    setZoomedImage()
    dismiss(animated: true)
  }

  func setZoomedImage() {
//    let cgImage = photoImageView.image?.cgImage
//    let rect = CGRect(origin: colorPickerView.center, size: CGSize(width: 100, height: 100))
//    let croppedImage = cgImage?.cropping(to: rect)
//    zoomedImageView.image = UIImage(cgImage: croppedImage!)
  }

  func calculateZoomScale() {
    let imageSize = photoImageView.image!.size
    let ratioH = imageSize.height/(view.frame.height/4)
    let ratioW = imageSize.width/(view.frame.width/4)
    let ratio = max(ratioH, ratioW)
    scrollView.maximumZoomScale = max(ratio, 4)
  }

  func setImage(_ image: UIImage?) {
    photoImageView.image = image
    photoImageView.backgroundColor = UIColor(white: 0.95, alpha: 1)
    photoImageView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
      self.photoImageView.transform = .identity
    })
    scrollView.isUserInteractionEnabled = true

    colorPickerView.isHidden = false
    colorInfoView.isHidden = false
    tipStackView.isHidden = true
    pickButton.isHidden = false

    let center = CGPoint(x: view.frame.width/2, y: view.frame.height/2)
    colorPickerView.center = center
    colorPickerView.shapeLayer.fillColor = UIColor.clear.cgColor
    let color = photoImageView.layer.pickColor(at: center)
    colorPickerView.shapeLayer.fillColor = color!.cgColor
    moved(to: color!)
  }
}

extension LibraryController: ColorPickerDelegate {
  func endedMovement() {
    doubleTapGesture.isEnabled = true
    scrollView.isScrollEnabled = true
  }

  func beganMovement() {
    doubleTapGesture.isEnabled = false
    scrollView.isScrollEnabled = false
  }

  func moved(to color: UIColor) {
    colorInfoView.set(color: color)
    colorPickerView.color = color
    setZoomedImage()
  }
}

extension LibraryController: UIViewControllerTransitioningDelegate {
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return AnimationController(duration: 0.4, type: .present, direction: .horizontal)
  }

  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return AnimationController(duration: 0.4, type: .dismiss, direction: .horizontal)
  }
}

//MARK: - ColorInfoDelegate
extension LibraryController: ColorInfoDelegate {
  func presentColorController() {
    let colorController = ColorController()
    colorController.updateColorsArchive = updateColorsArchive
    colorController.set(color: colorInfoView.color!)
    colorController.modalPresentationStyle = .fullScreen
    present(colorController, animated: true)
  }
}

extension CALayer {
  public func pickColor(at position: CGPoint) -> UIColor? {
    var pixel = [UInt8](repeatElement(0, count: 4))
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
    guard let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo) else {
      return nil
    }
    context.translateBy(x: -position.x, y: -position.y)
    render(in: context)

    return UIColor(red: CGFloat(pixel[0]) / 255.0,
                   green: CGFloat(pixel[1]) / 255.0,
                   blue: CGFloat(pixel[2]) / 255.0,
                   alpha: CGFloat(pixel[3]) / 255.0)
  }
}
