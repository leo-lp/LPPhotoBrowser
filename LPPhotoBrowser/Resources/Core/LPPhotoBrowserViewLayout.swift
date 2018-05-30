//
//  LPPhotoBrowserViewLayout.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/5/29.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

class LPPhotoBrowserViewLayout: UICollectionViewFlowLayout {
    var distanceBetweenPages: CGFloat = 18.0
    
    override func prepare() {
        super.prepare()
        scrollDirection = .horizontal
        
        guard let collectionView = collectionView else { return }
        itemSize = collectionView.frame.size
        minimumLineSpacing = 0.0
        minimumInteritemSpacing = 0.0
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let layoutAttsArray = super.layoutAttributesForElements(in: rect)
            else { return nil }
        
        guard let collectionView = collectionView else {
            return layoutAttsArray
        }
        
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2.0
        
        var min = CGFloat.greatestFiniteMagnitude
        var minIdx: Int = 0
        for (idx, atts) in layoutAttsArray.enumerated() {
            let absValue = abs(centerX-atts.center.x)
            if absValue < min {
                min = absValue
                minIdx = idx
            }
        }
        
        for (idx, atts) in layoutAttsArray.enumerated() {
            if minIdx - 1 == idx {
                let x = atts.center.x - distanceBetweenPages
                atts.center = CGPoint(x: x, y: atts.center.y)
            }
            if minIdx + 1 == idx {
                let x = atts.center.x + distanceBetweenPages
                atts.center = CGPoint(x: x, y: atts.center.y)
            }
        }
        return layoutAttsArray
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
