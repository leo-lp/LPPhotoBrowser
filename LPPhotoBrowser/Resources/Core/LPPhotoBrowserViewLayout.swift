//
//  LPPhotoBrowserViewLayout.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/5/29.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

class LPPhotoBrowserViewLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        scrollDirection = .horizontal
        
        guard let collectionView = collectionView else { return }
        itemSize = collectionView.frame.size
        minimumLineSpacing = 0.0
        minimumInteritemSpacing = 0.0
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        print("rect=\(rect)")
        guard let layoutAttsArray = super.layoutAttributesForElements(in: rect)
            else { return nil }
        
        guard let collectionView = collectionView else {
            return layoutAttsArray
        }
        
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2.0
        
        var currValue = CGFloat.greatestFiniteMagnitude
        var currIdx: Int = 0
        for (idx, atts) in layoutAttsArray.enumerated() {
            let absValue = abs(centerX-atts.center.x)
            if absValue < currValue {
                currValue = absValue
                currIdx = idx
            }
        }
        
        let leftIdx = currIdx - 1
        let rightIdx = currIdx + 1
        
        // 页间距
        let distance = LPPhotoBrowserConfig.shared.distanceBetweenPages
        
        /// 获取当前用户界面布局方向
        let attribute = UIView.appearance().semanticContentAttribute
        let direction = UIView.userInterfaceLayoutDirection(for: attribute)
        let isLeftToRight = direction == .leftToRight
        
        var attributes: [UICollectionViewLayoutAttributes] = []
        for (idx, atts) in layoutAttsArray.enumerated() {
            let attsCopy = atts.copy() as! UICollectionViewLayoutAttributes
            
            if leftIdx == idx {
                let x: CGFloat
                if isLeftToRight {
                    x = attsCopy.center.x - distance
                } else {
                    x = attsCopy.center.x + distance
                }
                attsCopy.center = CGPoint(x: x, y: atts.center.y)
            }
            if rightIdx == idx {
                let x: CGFloat
                if isLeftToRight {
                    x = attsCopy.center.x + distance
                } else {
                    x = attsCopy.center.x - distance
                }
                attsCopy.center = CGPoint(x: x, y: atts.center.y)
            }
            
            attributes.append(attsCopy)
        }
        return attributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
