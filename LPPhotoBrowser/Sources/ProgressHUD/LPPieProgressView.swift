//
//  LPPieProgressView.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/6/22.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

class LPPieProgressView: LPBaseProgressView {

    deinit {
        #if DEBUG
        print("LPPieProgressView: -> release memory.")
        #endif
    }

    override class var layerClass: AnyClass {
        return LPPieProgressLayer.self
    }
}

class LPPieProgressLayer: LPBaseProgressLayer {

    override func draw(in ctx: CGContext) {
        UIGraphicsPushContext(ctx)
        let rect = bounds

        let lineWidth: CGFloat = 2.0
        let center = CGPoint(x: rect.origin.x + floor(rect.width / 2.0),
                             y: rect.origin.y + floor(rect.height / 2.0))
        let radius: CGFloat = floor(min(rect.width, rect.height) / 2.0) - lineWidth

        let borderPath = UIBezierPath(arcCenter: center,
                                      radius: radius,
                                      startAngle: 0.0,
                                      endAngle: CGFloat.pi * 2.0,
                                      clockwise: false)
        borderPath.lineWidth = lineWidth

        fillColor.setFill()
        borderPath.fill()

        color.set()
        borderPath.stroke()

        let startAngle = -(CGFloat.pi / 2.0)
        let endAngle = startAngle + CGFloat.pi * 2.0 * CGFloat(progress)
        let processPath = UIBezierPath(arcCenter: center,
                                       radius: radius / 2.0,
                                       startAngle: startAngle,
                                       endAngle: endAngle,
                                       clockwise: true)
        processPath.lineWidth = radius
        processPath.stroke()

        UIGraphicsPopContext()
    }
}
