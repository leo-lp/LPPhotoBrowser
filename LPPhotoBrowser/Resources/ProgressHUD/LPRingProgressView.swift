//
//  LPRingProgressView.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/6/22.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

class LPRingProgressView: LPBaseProgressView {

    deinit {
        #if DEBUG
        print("LPRingProgressView: -> release memory.")
        #endif
    }

    override class var layerClass: AnyClass {
        return LPRingProgressLayer.self
    }

//    override func commonInit() {
//        super.commonInit()
//        layer.opacity = 1
//
//        /// 设置默认阴影风格
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
//        layer.shadowOpacity = 0.5
//        layer.shadowRadius = 2.0
//    }
}

class LPRingProgressLayer: LPBaseProgressLayer {

    override func draw(in ctx: CGContext) {
        UIGraphicsPushContext(ctx)
        let rect = bounds

        let lineWidth: CGFloat = 5.0
        let center = CGPoint(x: rect.origin.x + floor(rect.width / 2.0),
                             y: rect.origin.y + floor(rect.height / 2.0))
        let radius: CGFloat = floor(min(rect.width, rect.height) / 2.0) - lineWidth
        let startAngle = -(CGFloat.pi / 2.0)
        let endAngle = startAngle + CGFloat.pi * 2.0 * CGFloat(progress)
        let processPath = UIBezierPath(arcCenter: center,
                                       radius: radius,
                                       startAngle: startAngle,
                                       endAngle: endAngle,
                                       clockwise: true)
        processPath.lineWidth = lineWidth
        processPath.lineCapStyle = .round

        color.setStroke()
        processPath.stroke()

        UIGraphicsPopContext()
    }
}
