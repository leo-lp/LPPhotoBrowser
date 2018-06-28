//
//  LPBaseProgressView.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/6/22.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

// MARK: -
// MARK: - Base Progress View

class LPBaseProgressView: UIView {

    // MARK: - Public Property
    
    /// 进度条颜色
    var color: UIColor = UIColor(white: 1.0, alpha: 1.0) {
        didSet {
            if color != oldValue { (layer as? LPBaseProgressLayer)?.color = color }
        }
    }
    
    /// 进度条背景填充颜色
    var fillColor: UIColor = UIColor(white: 1.0, alpha: 0.1) {
        didSet {
            if fillColor != oldValue { (layer as? LPBaseProgressLayer)?.fillColor = fillColor }
        }
    }
    
    /// 进度值
    var progress: Float {
        get { return smoothProgress }
        set { setProgress(newValue, animated: false) }
    }
    
    func setProgress(_ newValue: Float, animated: Bool) {
        let newSmoothProgress = calculationSmoothProgress(with: newValue)
        guard smoothProgress != newSmoothProgress else { return }
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(animated ? 0.25 : 0.0)
        smoothProgress = newSmoothProgress
        CATransaction.commit()
        
    }
    
    /// 视图隐藏后是否自动清空进度值；默认true
    var cleanWhenHidden: Bool = true
    
    // MARK: - override Func
    
    deinit {
        #if DEBUG
        print("LPBaseProgressView: -> release memory.")
        #endif
    }
    
    override class var layerClass: AnyClass {
        return LPBaseProgressLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        isOpaque = false
        backgroundColor = UIColor.clear
        
        if let layer = layer as? LPBaseProgressLayer {
            layer.contentsScale = UIScreen.main.scale
            layer.color = color
            layer.fillColor = fillColor
            layer.progress = progress
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let contentSize = frame.size
        if contentSize == .zero {
            return CGSize(width: 37.0, height: 37.0)
        } else {
            return contentSize
        }
    }
    
    override var isHidden: Bool {
        didSet {
            if isHidden && cleanWhenHidden {
                smoothProgress = 0.0
            }
        }
    }
    
    // MARK: - Private Func
    
    private var smoothProgress: Float = 0.0 {
        didSet {
            if smoothProgress != oldValue {
                (layer as? LPBaseProgressLayer)?.progress = smoothProgress
            }
        }
    }
    
    private func calculationSmoothProgress(with newValue: Float) -> Float {
        var newProgress = smoothProgress
        if newValue.isNaN { return newProgress }
        
        let diff = newValue - smoothProgress
        if diff > 0.0 {
            newProgress = newValue
        } else if diff == 0.0 {
            if newValue == 0.0 {
                newProgress += 0.2
            } else if newValue < 0.8 {
                newProgress += 0.02
            }
        } else {
            if newValue == 0.0 && smoothProgress < 0.8 {
                newProgress += 0.2
            } else if smoothProgress < 0.8 {
                newProgress += 0.02
            }
        }
        
        if newProgress > 1.0 {
            newProgress = 1.0
        }
        return newProgress
    }
}

// MARK: -
// MARK: - Base Progress Layer

class LPBaseProgressLayer: CALayer {
    @NSManaged var progress: Float
    @NSManaged var color: UIColor
    @NSManaged var fillColor: UIColor

    override class func needsDisplay(forKey key: String) -> Bool {
        return (key == "progress" || key == "color" || key == "fillColor" || super.needsDisplay(forKey: key))
    }

    override func action(forKey event: String) -> CAAction? {
        if event == "progress" {
            let progressAnimation = CABasicAnimation(keyPath: event)
            progressAnimation.fromValue = presentation()?.value(forKey: event)
            progressAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            return progressAnimation
        }
        return super.action(forKey: event)
    }

    override func draw(in ctx: CGContext) {

    }
}
