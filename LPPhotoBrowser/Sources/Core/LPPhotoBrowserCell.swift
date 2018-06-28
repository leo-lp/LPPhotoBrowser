//
//  LPPhotoBrowserCell.swift
//  LPPhotoBrowser
//
//  Created by 李鹏 on 2018/6/1.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

class LPPhotoBrowserCell: LPBaseBrowserCell {
    let containerView = LPPhotoContainerView()
    
    override func bindData(_ source: LPPhotoBrowserSourceConvertible?, delegate: LPBrowserCellDelegate?) {
        containerView.bindData(source, delegate: delegate)
    }
    
    override func setupSubviews() {
        addSubview(containerView)
    }
    
    func recoverSubviews() {
        containerView.recoverSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = bounds
    }
}
