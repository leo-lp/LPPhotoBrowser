//
//  LPPhotoBrowserModels.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/5/29.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

public struct LPPhotoBrowserType: OptionSet, Hashable {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    public static let `default` = LPPhotoBrowserType(rawValue: 1 << 1)
    public static let network   = LPPhotoBrowserType(rawValue: 1 << 2)
    public static let album     = LPPhotoBrowserType(rawValue: 1 << 3)
}

public typealias LPProgress = (_ percent: Float) -> Void
public typealias LPCompletion = (_ image: UIImage?) -> Void
public typealias LPCompletion2 = (_ data: Data?) -> Void

public protocol LPPhotoBrowserSourceConvertible {
    /// 获取当前显示图片，用于视图控制器过渡动画
    var asCurrentImage: UIImage? { get }
    
    /// 图片占位符
    var asPlaceholder: UIImage? { get }
    
    /// 获取缩略图
    func asThumbnail(_ progress: LPProgress?, completion: @escaping LPCompletion)
    
    /// 获取原图
    func asOriginal(_ progress: LPProgress?, completion: @escaping LPCompletion)
    
    /// 获取数据，用于将图片存储到相册
    func asData(_ progress: LPProgress?, completion: @escaping LPCompletion2)
}

extension UIImage: LPPhotoBrowserSourceConvertible {
    public var asCurrentImage: UIImage? { return self }
    public var asPlaceholder: UIImage? { return nil }
    
    public func asThumbnail(_ progress: LPProgress?, completion: @escaping LPCompletion) {
        completion(nil)
    }
    
    public func asOriginal(_ progress: LPProgress?, completion: @escaping LPCompletion) {
        completion(self)
    }
    
    public func asData(_ progress: LPProgress?, completion: @escaping LPCompletion2) {
        return completion(UIImagePNGRepresentation(self) ?? UIImageJPEGRepresentation(self, 1.0))
    }
}
