//
//  UIViewController+LPKit.swift
//  LPKit <https://github.com/leo-lp/LPKit>
//
//  Created by pengli on 2018/5/28.
//  Copyright © 2018年 pengli. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit

extension UIViewController {
    
    /// 获取Window中的顶视图控制器
    static func topController(_ viewCtrl: UIViewController? = nil) -> UIViewController? {
        let viewCtrl = viewCtrl ?? UIApplication.shared.keyWindow?.rootViewController
        
        if let navCtrl = viewCtrl as? UINavigationController
            , let last = navCtrl.viewControllers.last {
            return topController(last)
            
        } else if let tabBarCtrl = viewCtrl as? UITabBarController
            , let selectedCtrl = tabBarCtrl.selectedViewController {
            return topController(selectedCtrl)
            
        } else if let presentedCtrl = viewCtrl?.presentedViewController {
            return topController(presentedCtrl)
        }
        
        return viewCtrl
    }
}
