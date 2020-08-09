//
//  ColorPicker.swift
//  Tint
//
//  Created by debavlad on 02.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

protocol ColorPickerDelegate {
  func beganMovement()
  func moved(to color: UIColor)
  func endedMovement()
}

final class ColorPicker: UIView {
  let shapeLayer = CAShapeLayer()
  var color: UIColor = .white
  private var defaultScale: CGFloat {
    let scrollView = superview?.superview as! UIScrollView
    return 1/scrollView.zoomScale
  }
  private lazy var location: CGPoint = {
    return center
  }()
  var delegate: ColorPickerDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupShapeLayer()
    setupPanRecognizer()
  }
  
  private func setupShapeLayer() {
    let lineWidth: CGFloat = 1.25
    let inset: CGFloat = lineWidth/2
    
    let circlePath = UIBezierPath(ovalIn: frame.insetBy(dx: inset, dy: inset))
    shapeLayer.path = circlePath.cgPath
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeColor = UIColor.white.cgColor
    shapeLayer.lineWidth = lineWidth
    shapeLayer.shadowColor = UIColor.black.cgColor
    shapeLayer.shadowRadius = 3
    shapeLayer.shadowOpacity = 0.25
    shapeLayer.shadowOffset = CGSize(width: 0, height: 0)
    layer.addSublayer(shapeLayer)
  }
  
  private func setupPanRecognizer() {
    let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    panRecognizer.delaysTouchesBegan = false
    self.gestureRecognizers = [panRecognizer]
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    delegate?.beganMovement()
    turnToRing()
    UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.2)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    delegate?.endedMovement()
    turnToCircle()
    UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.2)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Gesture actions
extension ColorPicker {
  @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
    switch recognizer.state {
      case .began:
        location = center
      case .changed:
        let translation = recognizer.translation(in: self.superview)
        locationChanged(with: translation)
      case .ended:
        delegate?.endedMovement()
        turnToCircle()
      default:
        break
    }
  }
  
  private func locationChanged(with translation: CGPoint = .zero) {
    center = CGPoint(x: location.x + translation.x,
                     y: location.y + translation.y)
    guard let imageView = superview as? UIImageView else {
      return
    }
    let color = imageView.layer.pickColor(at: center)
    set(color: color!)
    delegate?.moved(to: color!)
  }
  
  private func set(color: UIColor) {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    shapeLayer.strokeColor = color.cgColor
    CATransaction.commit()
  }
  
  private func turnToCircle() {
    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.curveLinear, .allowUserInteraction], animations: {
      self.transform = CGAffineTransform(scaleX: self.defaultScale, y: self.defaultScale)
    })
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    shapeLayer.fillColor = color.cgColor
    shapeLayer.shadowOpacity = 0.25
    CATransaction.commit()

    shapeLayer.strokeColor = UIColor.white.cgColor
    shapeLayer.lineWidth = 1.3
  }
  
  private func turnToRing() {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    shapeLayer.lineWidth = 5
    shapeLayer.strokeColor = color.cgColor
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.shadowOpacity = 0.15
    CATransaction.commit()
    
    let scale = defaultScale * 2.25
    UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [.curveEaseOut, .allowUserInteraction], animations: {
      self.transform = CGAffineTransform(scaleX: scale, y: scale)
    })
  }
}
