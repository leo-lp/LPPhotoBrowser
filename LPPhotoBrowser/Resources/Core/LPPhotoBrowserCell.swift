//
//  LPPhotoBrowserCell.swift
//  LPPhotoBrowser
//
//  Created by 李鹏 on 2018/6/1.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

class LPPhotoBrowserCell: LPBaseBrowserCell {
    //@property (nonatomic, copy) void (^imageProgressUpdateBlock)(double progress);
    
    let containerView = LPPhotoContainerView()
    
    override var source: LPPhotoBrowserSource? {
        didSet { containerView.source = source }
    }
    
    override func setupSubviews() {
        //    __weak typeof(self) weakSelf = self;
        //    [self.previewView setSingleTapGestureBlock:^{
        //        __strong typeof(weakSelf) strongSelf = weakSelf;
        //        if (strongSelf.singleTapGestureBlock) {
        //            strongSelf.singleTapGestureBlock();
        //        }
        //    }];
        //    [self.previewView setImageProgressUpdateBlock:^(double progress) {
        //        __strong typeof(weakSelf) strongSelf = weakSelf;
        //        if (strongSelf.imageProgressUpdateBlock) {
        //            strongSelf.imageProgressUpdateBlock(progress);
        //        }
        //    }];
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
