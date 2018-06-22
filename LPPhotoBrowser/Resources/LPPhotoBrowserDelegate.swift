//
//  LPPhotoBrowserDelegate.swift
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
