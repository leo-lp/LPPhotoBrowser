//
//  LPPhotoBrowserAnimatedOptions.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/5/29.
//  Copyright © 2018年 pengli. All rights reserved.
//

import Foundation

enum LPPhotoBrowserTransitionAnimation {
    case none // 无动画
    case fade // 渐隐
    case move // 移动
}

struct LPPhotoBrowserAnimatedOptions {
    /// 转场动画持续时间
    static var transitionDuration: TimeInterval = 0.25
    
    /// 入场/出场动画类型
    static var transitionAnimation: LPPhotoBrowserTransitionAnimation = .move
    
}
