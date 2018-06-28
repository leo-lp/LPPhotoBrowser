//
//  LPPhotoBrowserProtocol.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/5/28.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

// MARK: -
// MARK: - LPPhotoBrowser dataSource delegate

public protocol LPPhotoBrowserDataSource: class {
    /// 配置图片的数量
    func photoBrowser(_ browser: LPPhotoBrowser, numberOf type: LPPhotoBrowserType) -> Int
    func photoBrowser(_ browser: LPPhotoBrowser, sourceAt index: Int, of type: LPPhotoBrowserType) -> LPPhotoBrowserSourceConvertible?
    func photoBrowser(_ browser: LPPhotoBrowser, imageViewOfClickedAt index: Int, of type: LPPhotoBrowserType) -> UIImageView?
    
    /// NOTE: optional
    func navigationBar(in browser: LPPhotoBrowser) -> (UIView & LPNavigationBarDataSource)?
}
extension LPPhotoBrowserDataSource {
    public func navigationBar(in browser: LPPhotoBrowser) -> (UIView & LPNavigationBarDataSource)? {
        let top = UIApplication.shared.lp_safeAreaInsets.top
        let width = UIScreen.main.bounds.width
        let height = (top == 0.0 ? 20.0 : top) + 44.0
        return LPNavigationBar(frame: CGRect(x: 0, y: 0, width: width, height: height))
    }
}

public protocol LPPhotoBrowserDelegate: class {
    /// NOTE: optional
    func photoBrowser(_ browser: LPPhotoBrowser, indexDidChange oldIndex: Int, newIndex: Int, of type: LPPhotoBrowserType)
    func shouldLongPressGestureHandle() -> Bool
}
extension LPPhotoBrowserDelegate {
    public func photoBrowser(_ browser: LPPhotoBrowser, indexDidChange oldIndex: Int, newIndex: Int, of type: LPPhotoBrowserType) {}
    public func shouldLongPressGestureHandle() -> Bool { return true }
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
