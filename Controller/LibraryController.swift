//
//  LibraryController.swift
//  Tint
//
//  Created by debavlad on 01.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

final class LibraryController: UIViewController {
  var bottomBarConstraint: NSLayoutAnchor<NSLayoutYAxisAnchor>? {
    didSet {
      setupBarButtons()
    }
  }
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
      APIManager.shared.set(colors: colors)
      updateColorsArchive?()
    }

    calculateImageInsets()
    setupTipViews()
    setupSubviews()
    setupDoubleTapRecognizer()
    setupImagePicker()
  }

  var imageInsets: (top: CGFloat, bottom: CGFloat, height: CGFloat)!

  private func calculateImageInsets() {
    if Device.shared.hasNotch {
      imageInsets = (150, -150, -300)
    } else {
      imageInsets = (110, -160, -270)
    }
  }

  private func setupBarButtons() {
    pickButton.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
    pickButton.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(pickButton)
    NSLayoutConstraint.activate([
      pickButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -22.5),
      pickButton.bottomAnchor.constraint(equalTo: bottomBarConstraint!, constant: -20)
    ])
  }

  @objc private func openImagePicker() {
    present(imagePicker, animated: true)
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    openImagePicker()
  }

  private func setupTipViews() {
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

  private func setupSubviews() {
    scrollView.delegate = self
    scrollView.isUserInteractionEnabled = false
    scrollView.contentInsetAdjustmentBehavior = .never
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
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
    let topMargin: CGFloat = Device.shared.hasNotch ? 15 : 20
    NSLayoutConstraint.activate([
      colorInfoView.widthAnchor.constraint(equalToConstant: 172),
      colorInfoView.heightAnchor.constraint(equalToConstant: 70),
      colorInfoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      colorInfoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topMargin)
    ])

    NSLayoutConstraint.activate([
      photoImageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      photoImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: imageInsets.top),
      photoImageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      photoImageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: imageInsets.bottom),
      photoImageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
      photoImageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, constant: imageInsets.height)
    ])
  }

  private func setupDoubleTapRecognizer() {
    doubleTapGesture.addTarget(self, action: #selector(handleDoubleTap(recognizer:)))
    doubleTapGesture.numberOfTapsRequired = 2
    doubleTapGesture.delaysTouchesBegan = false
    doubleTapGesture.delaysTouchesEnded = false
    scrollView.addGestureRecognizer(doubleTapGesture)
  }

  private func setupImagePicker() {
    imagePicker.delegate = self
    if !Device.shared.hasNotch {
      imagePicker.modalPresentationStyle = .fullScreen
    }
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
    zoomRect.size.height = (photoImageView.frame.size.height - imageInsets.height) / scale
    zoomRect.size.width  = photoImageView.frame.size.width  / scale

    let newCenter = scrollView.convert(center, from: photoImageView)
    zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
    zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0) + imageInsets.height
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
    let newSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)

    var hInset: CGFloat = 0
    if newSize.width * scale > photoImageView.frame.width {
      hInset = (newSize.width - photoImageView.frame.width)/2 + 20
    } else {
      hInset = (scrollView.frame.width - scrollView.contentSize.width)/2
    }

    var vInset: CGFloat = 0
    if newSize.height * scale > photoImageView.frame.height {
      vInset = (newSize.height - photoImageView.frame.height)/2
    } else {
      vInset = (scrollView.frame.height - scrollView.contentSize.height)/2
    }

    scrollView.contentInset = UIEdgeInsets(top: vInset, left: hInset, bottom: vInset - imageInsets.height, right: hInset)
  }
}

extension LibraryController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    setImage(info[.originalImage] as? UIImage)
    calculateZoomScale()
    dismiss(animated: true)
  }

  func calculateZoomScale() {
    let imageSize = photoImageView.image!.size
    let ratioH = imageSize.height/(view.frame.height/4)
    let ratioW = imageSize.width/(view.frame.width/4)
    let ratio = max(ratioH, ratioW)
    scrollView.maximumZoomScale = max(ratio, 4)
  }

  func resizedImage(_ image: UIImage, to scale: CGFloat) -> UIImage {
    let height = image.size.height * scale
    let width = image.size.width * scale
    UIGraphicsBeginImageContext(CGSize(width: width, height: height))
    image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
  }

  func appropriateScale(for image: UIImage) -> CGFloat {
    let maxSideLength: CGFloat = 2100
    let largestSide = max(image.size.width, image.size.height)
    let scale = maxSideLength / largestSide
    return min(1, scale)
  }

  func setImage(_ image: UIImage?) {
    let scale = appropriateScale(for: image!)
    let compressedImage = resizedImage(image!, to: scale)

    photoImageView.image = compressedImage
    photoImageView.backgroundColor = UIColor(white: 0.95, alpha: 1)
    photoImageView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
      self.photoImageView.transform = .identity
    })
    scrollView.contentInset = .zero
    scrollView.isUserInteractionEnabled = true
    scrollView.zoomScale = 1

    colorPickerView.transform = .identity
    colorPickerView.isHidden = false
    colorInfoView.isHidden = false
    tipStackView.isHidden = true
    pickButton.isHidden = false

    let center = CGPoint(x: photoImageView.frame.width/2,
                         y: photoImageView.frame.height/2)
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
    colorController.configure(with: colorInfoView.color!)
    colorController.modalPresentationStyle = .fullScreen
    present(colorController, animated: true)
  }
}

extension CALayer {
  func pickColor(at position: CGPoint) -> UIColor? {
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
