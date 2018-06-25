//
//  LPPhotoBrowserProtocol.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/5/28.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

public protocol LPPhotoBrowserDataSource: class {
    
    /// 配置图片的数量
    func photoBrowser(_ browser: LPPhotoBrowser,
                      numberOf type: LPPhotoBrowserType) -> Int
    
    func photoBrowser(_ browser: LPPhotoBrowser,
                      sourceAt index: Int,
                      of type: LPPhotoBrowserType) -> LPPhotoBrowserSourceConvertible?
    
    func photoBrowser(_ browser: LPPhotoBrowser,
                      imageViewOfClickedAt index: Int,
                      of type: LPPhotoBrowserType) -> UIImageView?
    
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
    func photoBrowser(_ browser: LPPhotoBrowser,
                      indexDidChange oldIndex: Int,
                      newIndex: Int,
                      of type: LPPhotoBrowserType)
}

extension LPPhotoBrowserDelegate {
    public func photoBrowser(_ browser: LPPhotoBrowser,
                             indexDidChange oldIndex: Int,
                             newIndex: Int,
                             of type: LPPhotoBrowserType) {}
}
