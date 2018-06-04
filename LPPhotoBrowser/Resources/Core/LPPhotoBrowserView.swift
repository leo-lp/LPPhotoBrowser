//
//  LPPhotoBrowserView.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/5/29.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

private let LPCellID = "LPPhotoBrowserCellID"
class LPPhotoBrowserView: UICollectionView {
    
    deinit {
        log.warning("release memory.")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        backgroundColor = UIColor.clear
        
        isPagingEnabled = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        alwaysBounceVertical = false
        
        register(LPPhotoBrowserCell.self,
                 forCellWithReuseIdentifier: LPCellID)
        
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
    }
    
    func scrollToIndex(_ index: Int) {
        let offset = CGPoint(x: bounds.width * CGFloat(index),
                             y: 0)
        contentOffset = offset
    }
    
    func configCell(with source: LPPhotoBrowserSource?,
                    delegate: LPBrowserCellDelegate,
                    at indexPath: IndexPath) -> LPPhotoBrowserCell {
        let cell = dequeueReusableCell(withReuseIdentifier: LPCellID,
                                       for: indexPath) as! LPPhotoBrowserCell
        cell.bindData(source, delegate: delegate)
        return cell
    }
}

// MARK: - Private funcs

extension LPPhotoBrowserView {
    @objc private func deviceOrientationDidChange() {
//        reloadData()
//        layoutIfNeeded()
//        scrollToPageIndex(currentIndex)
    }
}
