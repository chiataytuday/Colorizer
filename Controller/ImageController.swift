//
//  ImageController.swift
//  Tint
//
//  Created by debavlad on 01.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

final class ImageController: UIViewController {
  private let scrollView = UIScrollView()
  private let imagePicker = UIImagePickerController()
  private var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  private var colorTrackerView = ColorTrackerView()
  private let doubleTapGesture = UITapGestureRecognizer()
  private var colorPickerView: PipetteView!
  private var tipStackView: UIStackView!
  var delegate: ColorsArchiveUpdating?

  private let imageInsets: (top: CGFloat, bottom: CGFloat, height: CGFloat) = {
    return Device.shared.hasNotch ? (150, -150, -300) : (110, -160, -270)
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(white: 0.95, alpha: 1)
    
    layoutTipViews()
    setupScrollView()
    setupImageView()
    setupTools()
    setupGestures()
    setupImagePicker()
  }

  private func layoutTipViews() {
    let tipImageView = UIImageView(
      image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .light)))
    tipImageView.contentMode = .center
    tipImageView.tintColor = .lightGray

    let tipLabel = UILabel()
    tipLabel.text = "Tap to select photo"
    tipLabel.font = .systemFont(ofSize: 16.5, weight: .regular)
    tipLabel.textColor = .lightGray

    tipStackView = UIStackView(arrangedSubviews: [tipImageView, tipLabel])
    tipStackView.axis = .vertical
    tipStackView.spacing = 7.5
    view.addSubview(tipStackView)
    tipStackView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tipStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      tipStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }

  private func setupScrollView() {
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
  }

  private func setupImageView() {
    scrollView.addSubview(imageView)
    imageView.clipsToBounds = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.isUserInteractionEnabled = true
    NSLayoutConstraint.activate([
      imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      imageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: imageInsets.top),
      imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: imageInsets.bottom),
      imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
      imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, constant: imageInsets.height)
    ])
  }

  private func setupTools() {
    colorPickerView = PipetteView(frame: CGRect(origin: .zero, size: CGSize(width: 35, height: 35)))
    colorPickerView.delegate = self
    colorPickerView.isHidden = true
    imageView.addSubview(colorPickerView)
    colorPickerView.center = view.center

    colorTrackerView.delegate = self
    colorTrackerView.isHidden = true
    colorTrackerView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(colorTrackerView)
    let topMargin: CGFloat = Device.shared.hasNotch ? 15 : 20
    NSLayoutConstraint.activate([
      colorTrackerView.widthAnchor.constraint(equalToConstant: 160),
      colorTrackerView.heightAnchor.constraint(equalToConstant: 70),
      colorTrackerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      colorTrackerView.topAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.topAnchor,
        constant: topMargin)
    ])
  }

  private func setupGestures() {
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
}

extension ImageController {
  @objc private func handleDoubleTap(recognizer: UITapGestureRecognizer) {
    if scrollView.zoomScale == 1 {
      let center = recognizer.location(in: recognizer.view)
      scrollView.zoom(to: rectForScale(4, to: center), animated: true)
    } else {
      scrollView.setZoomScale(1, animated: true)
    }
  }

  private func rectForScale(_ scale: CGFloat, to center: CGPoint) -> CGRect {
    var rect: CGRect = .zero
    rect.size.height = (imageView.frame.height - imageInsets.height)/scale
    rect.size.width = imageView.frame.width/scale

    let newCenter = scrollView.convert(center, from: imageView)
    rect.origin.x = newCenter.x - (rect.size.width/2)
    rect.origin.y = newCenter.y - (rect.size.height/2) + imageInsets.height
    return rect
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    present(imagePicker, animated: true)
  }

  override var prefersStatusBarHidden: Bool {
    true
  }
}

// MARK: - UIScrollViewDelegate
extension ImageController: UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }

  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    let scale = scrollView.zoomScale
    colorPickerView.transform = CGAffineTransform(scaleX: 1/scale, y: 1/scale)
    guard scale <= scrollView.maximumZoomScale else { return }
    if scale <= 1 {
      scrollView.contentInset = .zero
      return
    }

    guard let image = imageView.image else { return }
    let wRatio = imageView.frame.width / image.size.width
    let hRatio = imageView.frame.height / image.size.height
    let ratio = min(wRatio, hRatio)
    let newSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)

    var hInset: CGFloat = 0
    if newSize.width * scale > imageView.frame.width {
      hInset = (newSize.width - imageView.frame.width)/2 + 20
    } else {
      hInset = (scrollView.frame.width - scrollView.contentSize.width)/2
    }

    var vInset: CGFloat = 0
    if newSize.height * scale > imageView.frame.height {
      vInset = (newSize.height - imageView.frame.height)/2
    } else {
      vInset = (scrollView.frame.height - scrollView.contentSize.height)/2
    }

    scrollView.contentInset = UIEdgeInsets(top: vInset, left: hInset, bottom: vInset - imageInsets.height, right: hInset)
  }
}

//MARK: - UINavigationControllerDelegate, UIImagePickerControllerDelegate
extension ImageController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    setImage(info[.originalImage] as? UIImage)
    defineMaxZoomScale()
    dismiss(animated: true)
  }

  func setImage(_ image: UIImage?) {
    guard let image = image else { return }
    let scale = image.maxScreenScale
    let compressedImage = image.scaled(to: scale)
    imageView.image = compressedImage
    imageView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
      self.imageView.transform = .identity
    })
    resetSubviews()

    guard !tipStackView.isHidden else { return }
    imageView.backgroundColor = UIColor(white: 0.95, alpha: 1)
    tipStackView.isHidden = true
    colorPickerView.isHidden = false
    colorTrackerView.isHidden = false
  }

  private func resetSubviews() {
    colorPickerView.transform = .identity
    scrollView.contentInset = .zero
    scrollView.isUserInteractionEnabled = true
    scrollView.zoomScale = 1

    let center = CGPoint(
      x: imageView.frame.width/2,
      y: imageView.frame.height/2)
    colorPickerView.center = center
    colorPickerView.shapeLayer.fillColor = UIColor.clear.cgColor
    let color = imageView.layer.pickColor(at: center)
    colorPickerView.shapeLayer.fillColor = color!.cgColor
    moved(to: color!)
  }

  private func defineMaxZoomScale() {
    guard let imageSize = imageView.image?.size else { return }
    let ratioH = imageSize.height/(view.frame.height/4)
    let ratioW = imageSize.width/(view.frame.width/4)
    let ratio = max(ratioH, ratioW)
    scrollView.maximumZoomScale = max(ratio, 4)
  }
}

//MARK: - PipetteDelegate
extension ImageController: PipetteDelegate {
  func endedMovement() {
    doubleTapGesture.isEnabled = true
    scrollView.isScrollEnabled = true
  }

  func beganMovement() {
    doubleTapGesture.isEnabled = false
    scrollView.isScrollEnabled = false
  }

  func moved(to color: UIColor) {
    colorTrackerView.configure(with: color)
    colorPickerView.color = color
  }
}

//MARK: - ColorPresenting
extension ImageController: ColorPresenting {
  func presentColorController() {
    let colorController = ColorController()
    colorController.delegate = delegate
    colorController.configure(with: colorTrackerView.color!)
    colorController.modalPresentationStyle = .fullScreen
    present(colorController, animated: true)
  }
}

// MARK: - CALayer
extension CALayer {
  func pickColor(at position: CGPoint) -> UIColor? {
    var pixel = [UInt8](repeatElement(0, count: 4))
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
    guard let context = CGContext(
      data: &pixel,
      width: 1,
      height: 1,
      bitsPerComponent: 8,
      bytesPerRow: 4,
      space: colorSpace,
      bitmapInfo: bitmapInfo) else {
        return nil
    }
    context.translateBy(x: -position.x, y: -position.y)
    render(in: context)

    return UIColor(
      red: CGFloat(pixel[0])/255.0,
      green: CGFloat(pixel[1])/255.0,
      blue: CGFloat(pixel[2])/255.0,
      alpha: CGFloat(pixel[3])/255.0)
  }
}

// MARK: - UIImage
extension UIImage {
  var maxScreenScale: CGFloat {
    let maxSideLength: CGFloat = 2100
    let largestSide = max(size.width, size.height)
    let scale = maxSideLength/largestSide
    return min(1, scale)
  }

  func scaled(to value: CGFloat) -> UIImage {
    let newSize = CGSize(
      width: size.width * scale,
      height: size.height * scale)
    UIGraphicsBeginImageContext(newSize)
    draw(in: CGRect(origin: .zero, size: newSize))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage ?? self
  }
}
