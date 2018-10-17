//
//  KnobRenderer.swift
//  KnobControl
//
//  Created by air on 2018/10/17.
//  Copyright © 2018年 com.wangliang. All rights reserved.
//

import Foundation
/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class KnobRenderer {
    var color: UIColor = .blue {
        didSet {
            trackLayer.strokeColor = color.cgColor
            pointerLayer.strokeColor = color.cgColor
        }
    }
    
    var lineWidth: CGFloat = 2 {
        didSet {
            trackLayer.lineWidth = lineWidth
            pointerLayer.lineWidth = lineWidth
            updateTrackLayerPath()
            updatePointerLayerPath()
        }
    }
    
    var startAngle: CGFloat = CGFloat(-Double.pi) * 11 / 8 {
        didSet {
            updateTrackLayerPath()
        }
    }
    
    var endAngle: CGFloat = CGFloat(Double.pi) * 3 / 8 {
        didSet {
            updateTrackLayerPath()
        }
    }
    
    var pointerLength: CGFloat = 6 {
        didSet {
            updateTrackLayerPath()
            updatePointerLayerPath()
        }
    }
    
    private (set) var pointerAngle: CGFloat = CGFloat(-Double.pi) * 11 / 8
    
    func setPointerAngle(_ newPointerAngle: CGFloat, animated: Bool = false) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        pointerLayer.transform = CATransform3DMakeRotation(newPointerAngle, 0, 0, 1)
        
        if animated {
            let midAngleValue = (max(newPointerAngle, pointerAngle) - min(newPointerAngle, pointerAngle)) / 2 + min(newPointerAngle, pointerAngle)
            let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
            animation.values = [pointerAngle, midAngleValue, newPointerAngle]
            animation.keyTimes = [0.0, 0.5, 1.0]
            animation.timingFunctions = [CAMediaTimingFunction(name: "easeInEaseOut")]
            pointerLayer.add(animation, forKey: nil)
        }
        
        CATransaction.commit()
        
        pointerAngle = newPointerAngle
    }
    
    let trackLayer = CAShapeLayer()
    let pointerLayer = CAShapeLayer()
    
    init() {
        trackLayer.fillColor = UIColor.clear.cgColor
        pointerLayer.fillColor = UIColor.clear.cgColor
    }
    
    private func updateTrackLayerPath() {
        let bounds = trackLayer.bounds
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let offset = max(pointerLength, lineWidth  / 2)
        let radius = min(bounds.width, bounds.height) / 2 - offset
        
        let ring = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        trackLayer.path = ring.cgPath
    }
    
    private func updatePointerLayerPath() {
        let bounds = trackLayer.bounds
        
        let pointer = UIBezierPath()
        pointer.move(to: CGPoint(x: bounds.width - CGFloat(pointerLength) - CGFloat(lineWidth) / 2, y: bounds.midY))
        pointer.addLine(to: CGPoint(x: bounds.width, y: bounds.midY))
        pointerLayer.path = pointer.cgPath
    }
    
    func updateBounds(_ bounds: CGRect) {
        trackLayer.bounds = bounds
        trackLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        updateTrackLayerPath()
        
        pointerLayer.bounds = trackLayer.bounds
        pointerLayer.position = trackLayer.position
        updatePointerLayerPath()
    }
}

import UIKit.UIGestureRecognizerSubclass

class RotationGestureRecognizer: UIPanGestureRecognizer {
    private(set) var touchAngle: CGFloat = 0
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        updateAngle(with: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        updateAngle(with: touches)
    }
    
    private func updateAngle(with touches: Set<UITouch>) {
        guard let touch = touches.first, let view = view else {
            return
        }
        let touchPoint = touch.location(in: view)
        touchAngle = angle(for: touchPoint, in: view)
    }
    
    private func angle(for point: CGPoint, in view: UIView) -> CGFloat {
        let centerOffset = CGPoint(x: point.x - view.bounds.midX, y: point.y - view.bounds.midY)
        return atan2(centerOffset.y, centerOffset.x)
    }
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        
        maximumNumberOfTouches = 1
        minimumNumberOfTouches = 1
    }
}
