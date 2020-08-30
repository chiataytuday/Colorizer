//
//  ColorPicker.swift
//  Tint
//
//  Created by debavlad on 02.07.2020.
//  Copyright © 2020 debavlad. All rights reserved.
//

import UIKit

/**
 A set of methods that should be called on the
 certain events related to the pipette movement.
 */
protocol PipetteDelegate {
  /// Pipette began movement.
  func beganMovement()

  /// Pipette moved.
  func moved(to color: UIColor)

  /// Pipette ended movement.
  func endedMovement()
}

/**
 A view that represents the **pipette tool**, which is used
 to pick colors from user's photo library.
 */
final class PipetteView: UIView {
  let shapeLayer = CAShapeLayer()
  var color: UIColor = .white
  private var defaultScale: CGFloat {
    let scrollView = superview?.superview as! UIScrollView
    return 1/scrollView.zoomScale
  }
  private lazy var location: CGPoint = {
    return center
  }()
  var delegate: PipetteDelegate?
  
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
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    delegate?.endedMovement()
    turnToCircle()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Gesture actions
extension PipetteView {
  /// Handles pipette pan gesture.
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

  /// Relocates the pipette using recognizer's translation.
  private func locationChanged(with translation: CGPoint = .zero) {
    center = CGPoint(
      x: location.x + translation.x,
      y: location.y + translation.y)
    
    guard let imageView = superview as? UIImageView,
      let color = imageView.layer.pickColor(at: center) else { return }
    setColor(color)
    delegate?.moved(to: color)
  }

  /// Sets `CAShapeLayer`'s `strokeColor` without transition.
  private func setColor(_ color: UIColor) {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    shapeLayer.strokeColor = color.cgColor
    CATransaction.commit()
  }

  /// Turns the `CAShapeLayer` to filled circle.
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

  /// Turns the `CAShapeLayer` to the ring.
  private func turnToRing() {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    shapeLayer.lineWidth = 6
    shapeLayer.strokeColor = color.cgColor
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.shadowOpacity = 0.15
    CATransaction.commit()
    
    let scale = defaultScale * 2.3
    UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [.curveEaseOut, .allowUserInteraction], animations: {
      self.transform = CGAffineTransform(scaleX: scale, y: scale)
    })
  }
}
