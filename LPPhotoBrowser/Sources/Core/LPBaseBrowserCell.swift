//
//  LPBaseBrowserCell.swift
//  LPPhotoBrowser
//
//  Created by 李鹏 on 2018/6/1.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

protocol LPBrowserCellDelegate: class {
    func imageViewClicked()
    func imageViewLongPressBegin()

    func dismissWhenEndDragging()
    func hideWhenStartDragging()
    func showWhenEndDragging()
    func show(with duration: TimeInterval)
    func changeAlphaWhenDragging(_ alpha: CGFloat)
}

class LPBaseBrowserCell: UICollectionViewCell {
    
    deinit {
        #if DEBUG
        print("LPBaseBrowserCell: -> release memory.")
        #endif
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        setupSubviews()
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoPreviewCollectionViewDidScroll) name:@"photoPreviewCollectionViewDidScroll" object:nil];
    }
    
    func bindData(_ source: LPPhotoBrowserSourceConvertible?,
                  delegate: LPBrowserCellDelegate?) {
    }
    
    func setupSubviews() {
        
    }
}
