//
//  LPPhotoBrowserConfig.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/5/29.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

//@interface YBImageBrowser ()
//<YBImageBrowserViewDelegate, YBImageBrowserViewDataSource, YBImageBrowserToolBarDelegate, YBImageBrowserFunctionBarDelegate>
//{
//    UIInterfaceOrientationMask supportAutorotateTypes;
//    UIWindow *window;
//    YBImageBrowserAnimatedTransitioning *animatedTransitioningManager;
//}
//
//@property (nonatomic, strong) YBImageBrowserView *browserView;
//@property (nonatomic, strong) YBImageBrowserToolBar *toolBar;
//@property (nonatomic, strong) YBImageBrowserFunctionBar *functionBar;
//
//@end

class LPPhotoBrowserConfig {
    static let shared: LPPhotoBrowserConfig = {
        return LPPhotoBrowserConfig()
    }()
    
    /// 纵屏时候图片填充类型
    var verticalScreenImageViewFillType: LPPhotoBrowserViewFillType = .fullWidth
    
    /// 横屏时候图片填充类型
    var horizontalScreenImageViewFillType: LPPhotoBrowserViewFillType = .fullWidth
    
    /// 取消拖拽图片的动画效果
    var cancelDragImageViewAnimation: Bool = false
    
    /// 拖拽图片动效触发出场的比例（拖动距离/屏幕高度 默认0.15）
    var outScaleOfDragImageViewAnimation: CGFloat = 0.15
    
    
}

//extension Notification.Name {
//    static let LPHideBrowerView = Notification.Name(rawValue: "com.lp.photoBrowser.notification.hideBrowerView")
//    //NSString * const YBImageBrowser_notification_hideBrowerView = @"YBImageBrowser_notification_hideBrowerView";
//}

//NSString * const YBImageBrowser_KVCKey_browserView = @"browserView";
//NSString * const YBImageBrowser_notification_willToRespondsDeviceOrientation = @"YBImageBrowser_notification_willToRespondsDeviceOrientation";
//NSString * const YBImageBrowser_notification_changeAlpha = @"YBImageBrowser_notification_changeAlpha";
//NSString * const YBImageBrowser_notificationKey_changeAlpha = @"YBImageBrowser_notificationKey_changeAlpha";

//NSString * const YBImageBrowser_notification_showBrowerView = @"YBImageBrowser_notification_showBrowerView";
//NSString * const YBImageBrowser_notification_willShowBrowerViewWithTimeInterval = @"YBImageBrowser_notification_willShowBrowerViewWithTimeInterval";
//NSString * const YBImageBrowser_notificationKey_willShowBrowerViewWithTimeInterval = @"YBImageBrowser_notification_willShowBrowerViewWithTimeInterval";
