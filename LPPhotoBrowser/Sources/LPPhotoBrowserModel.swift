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
    public static let local   = LPPhotoBrowserType(rawValue: 1 << 0)
    public static let network = LPPhotoBrowserType(rawValue: 1 << 1)
    public static let album   = LPPhotoBrowserType(rawValue: 1 << 2)
}


class LPPhotoBrowserConfig {
    static let shared: LPPhotoBrowserConfig = {
        return LPPhotoBrowserConfig()
    }()
    
    /// 取消拖拽图片的动画效果
    open var isDragAnimationEnabled: Bool = true
    
    /// 拖拽图片动效触发出场的比例（拖动距离/屏幕高度 默认0.15）
    var outScaleOfDragImageViewAnimation: CGFloat = 0.15
    
    /// 页与页之间的间距
    var distanceBetweenPages: CGFloat = 18.0
}
