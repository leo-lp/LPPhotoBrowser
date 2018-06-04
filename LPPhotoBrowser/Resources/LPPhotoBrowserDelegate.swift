//
//  LPPhotoBrowserDelegate.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/5/28.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

public enum LPPhotoBrowserType {
    case local
    case network
}

public enum LPPhotoBrowserSource {
    case image(UIImage?)
    case URL(UIImage?, URL?, URL?)
}

public protocol LPPhotoBrowserDataSource: class {
    
    /// 配置图片的数量
    func photoBrowser(_ browser: LPPhotoBrowser,
                      numberOf type: LPPhotoBrowserType) -> Int
    
    func photoBrowser(_ browser: LPPhotoBrowser,
                      sourceAt index: Int,
                      of type: LPPhotoBrowserType) -> LPPhotoBrowserSource
    
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

//#pragma mark 性能和内存相关 (performance and memory)
//
///**
// 网络图片下载和持久化时，是否做内存缓存，为YES能提高图片第二次显示的性能，为NO能减少图片的内存占用（高清大图请置NO）
// */
//@property (nonatomic, assign) BOOL downloaderShouldDecompressImages;
//
///**
// 最大显示pt（超过这个数量框架会自动做压缩和裁剪，默认为3500）
// */
//@property (class, assign) CGFloat maxDisplaySize;
//
//#pragma mark 其他 (other)
//
///**
// 文案撰写者
// （可依靠该属性配置自定义的文案）
// */
//@property (nonatomic, strong) YBImageBrowserCopywriter *copywriter;
//
///**
// 显示状态栏
// */
//@property (class, assign) BOOL showStatusBar;
