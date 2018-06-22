//
//  UIImage+LPKit.swift
//  LPKit <https://github.com/leo-lp/LPKit>
//
//  Created by pengli on 2018/5/21.
//  Copyright © 2018年 pengli. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit.UIImage

public extension UIImage {
    
    /// 等比缩放图像
    ///
    /// - Parameter scaleSize: 缩放比
    /// - Returns: 缩放后的图像
    func lp_scaleImage(_ scaleSize: CGFloat) -> UIImage {
        let toSize = CGSize(width: size.width * scaleSize,
                            height: size.height * scaleSize)
        UIGraphicsBeginImageContext(toSize)
        self.draw(in: CGRect(origin: .zero, size: toSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage ?? self
    }
    
    /// 自定长宽缩放图像
    ///
    /// - Parameter reSize: 缩放比
    /// - Returns: 缩放后的图像
    func lp_reSizeImage(_ reSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(reSize)
        self.draw(in: CGRect(origin: .zero, size: reSize))
        let reSizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return reSizeImage ?? self
    }
}

public extension UIImage {
    
    /// 图片水平翻转
    var lp_flipHorizontal: UIImage? {
        let orientationRawValue = (imageOrientation.rawValue + 4) % 8
        guard let orientation = UIImageOrientation(rawValue: orientationRawValue)
            , let cgImage = cgImage else { return nil }
        return UIImage(cgImage: cgImage, scale: scale, orientation: orientation)
    }
    
    /// 图片垂直翻转
    var lp_flipVertical: UIImage? {
        var orientationRawValue = (imageOrientation.rawValue + 4) % 8
        orientationRawValue += orientationRawValue % 2 == 0 ? 1 : -1
        
        guard let orientation = UIImageOrientation(rawValue: orientationRawValue)
            , let cgImage = cgImage else { return nil }
        return UIImage(cgImage: cgImage, scale: scale, orientation: orientation)
    }
}

// MARK: - 切圆角

public extension UIImage {
    
    /// 用指定的圆角尺寸切割图片
    ///
    /// - Parameters:
    ///   - radius: 每个圆角半径
    ///   - corners: 指定需要切割的角
    ///   - borderWidth: 边框宽
    ///   - borderColor: 边框颜色
    ///   - borderLineJoin: 边界线风格
    func lp_roundCorner(radius: CGFloat,
                        corners: UIRectCorner = .allCorners,
                        borderWidth: CGFloat = 0,
                        borderColor: UIColor? = nil,
                        borderLineJoin: CGLineJoin = .miter) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext()
            , let cgImage = cgImage else { return nil }
        
        let rect = CGRect(origin: .zero, size: size)
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -rect.size.height)
       
        let minSize: CGFloat = min(size.width, size.height)
        if borderWidth < minSize / 2 {
            let roundedRect = rect.insetBy(dx: borderWidth, dy: borderWidth)
            let cornerRadii = CGSize(width: radius, height: borderWidth)
            let path = UIBezierPath(roundedRect: roundedRect,
                                    byRoundingCorners: corners,
                                    cornerRadii: cornerRadii)
            path.close()
            context.saveGState()
            path.addClip()
            
            context.draw(cgImage, in: rect)
            context.restoreGState()
        }
        
        if let borderColor = borderColor
            , (borderWidth < minSize / 2 && borderWidth > 0) {
            
            let strokeInset = (floor(borderWidth * scale) + 0.5) / scale
            let strokeRect = rect.insetBy(dx: strokeInset, dy: strokeInset)
            let strokeRadius = radius > scale / 2 ? radius - scale / 2 : 0
            let cornerRadii = CGSize(width: strokeRadius, height: borderWidth)
            let path = UIBezierPath(roundedRect: strokeRect,
                                    byRoundingCorners: corners,
                                    cornerRadii: cornerRadii)
            path.close()
            
            path.lineWidth = borderWidth
            path.lineJoinStyle = borderLineJoin
           
            borderColor.setStroke()
            path.stroke()
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
