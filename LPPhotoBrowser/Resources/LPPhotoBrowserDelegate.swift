//
//  LPPhotoBrowserDelegate.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/5/28.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

public protocol LPPhotoBrowserDelegate: class {
    /// NOTE: optional
    
    func photoBrowser(_ browser: LPPhotoBrowser, didScrollTo index: Int)
    
    ///**
    // 点击功能栏的回调
    //
    // @param imageBrowser 当前图片浏览器
    // @param model 功能的数据model
    // */
    //- (void) clickFunctionBarWithModel:(YBImageBrowserFunctionModel *)model;
    
}

public protocol LPPhotoBrowserDataSource: class {
    /// NOTE: required
    
    /// 返回点击的那个 UIImageView（用于做 LPImageBrowserAnimationMove 类型动效）
    func imageViewOfTouch(in browser: LPPhotoBrowser) -> UIImageView?
    
    /// 配置图片的数量
    func numberOfPhotos(in browser: LPPhotoBrowser) -> Int
    
    // 返回当前 index 图片对应的数据模型
    func photoBrowser(_ browser: LPPhotoBrowser, modelForCellAt index: Int)
}

public extension LPPhotoBrowserDelegate {
    func photoBrowser(_ browser: LPPhotoBrowser, didScrollTo index: Int) { }
}


//@interface YBImageBrowser : UIViewController <YBImageBrowserScreenOrientationProtocol>
//
///**
// 数据源代理
// （请在设置 dataArray 和实现 dataSource 代理中选其一，注意 dataArray 优先级高于代理）
// */
//@property (nonatomic, weak) id <YBImageBrowserDataSource> dataSource;

///**
// 代理回调
// */
//@property (nonatomic, weak) id <YBImageBrowserDelegate> delegate;
//
//#pragma mark 功能栏操作 (function bar operation)
//
///**
// 弹出功能栏的数据源
// （默认有图片保存功能）
// */
//@property (nonatomic, copy, nullable) NSArray<YBImageBrowserFunctionModel *> *fuctionDataArray;
//
///**
// 弹出功能栏
// */
//@property (nonatomic, strong, readonly) YBImageBrowserFunctionBar *functionBar;
//
///**
// 工具栏
// */
//@property (nonatomic, strong, readonly) YBImageBrowserToolBar *toolBar;
//
//#pragma mark 动画相关 (animation)
///**
// 入场动画类型
// */
//@property (nonatomic, assign) YBImageBrowserAnimation inAnimation;
//
///**
// 出场动画类型
// */
//@property (nonatomic, assign) YBImageBrowserAnimation outAnimation;
//

//
//#pragma mark 屏幕方向相关 (screen direction)
//
///**
// 支持旋转的方向
// （请保证在 general -> deployment info -> Device Orientation 有对应的配置，目前不支持强制旋转）
// */
//@property (nonatomic, assign) UIInterfaceOrientationMask yb_supportedInterfaceOrientations;
//
//#pragma mark 缩放相关 (scale)

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
//
///**
// 进入图片浏览器之前状态栏是否隐藏（进入框架内部会判断，若在图片浏览器生命周期之间外部的状态栏显示与否发生改变，你需要改变该属性的值）
// */
//@property (class, assign) BOOL statusBarIsHideBefore;
//
///**
// 状态栏是否是控制器优先
// */
//@property (class, assign, readonly) BOOL isControllerPreferredForStatusBar;
//
//@end
//
//NS_ASSUME_NONNULL_END
