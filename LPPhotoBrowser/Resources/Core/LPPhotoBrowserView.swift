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
        print("----> scrollToIndex=\(index, bounds.width * CGFloat(index), contentOffset)")
        
        contentOffset = CGPoint(x: bounds.width * CGFloat(index), y: 0)
    }
    
    func configCell(with source: LPPhotoBrowserSource?, at indexPath: IndexPath) -> LPPhotoBrowserCell {
        let cell = dequeueReusableCell(withReuseIdentifier: LPCellID, for: indexPath) as! LPPhotoBrowserCell
        cell.source = source
        return cell
    }
}

// MARK: - Delegate funcs

extension LPPhotoBrowserView: LPPhotoBrowser_CellDelegate {
    // MARK: - LPPhotoBrowser_CellDelegate
    
    func photoBrowserCell(_ cell: LPPhotoBrowser_Cell, longPressBegin press: UILongPressGestureRecognizer) {
//        pb_delegate?.photoBrowserView(self, longPressBegin: press)
    }
    
    func applyHidden(by cell: LPPhotoBrowser_Cell) {
//        pb_delegate?.applyHidden(in: self)
    }
    
    func hideBrowerViewWhenStartDragging(in cell: LPPhotoBrowser_Cell) {
        guard !isHidden else { return }
        isHidden = true
    }
    
    func showBrowerViewWhenEndDragging(in cell: LPPhotoBrowser_Cell) {
//        pb_delegate?.showBrowerViewWhenEndDragging(in: self)
    }
    
    func photoBrowserCell(_ cell: LPPhotoBrowser_Cell, changeAlphaWhenDragging alpha: CGFloat) {
//        pb_delegate?.photoBrowserView(self, changeAlphaWhenDragging: alpha)
    }
    
    func photoBrowserCell(_ cell: LPPhotoBrowser_Cell, willShowBrowerViewWith timeInterval: TimeInterval) {
//        pb_delegate?.photoBrowserView(self, willShowBrowerViewWith: timeInterval)
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
