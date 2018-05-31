//
//  LPPhotoBrowserView.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/5/29.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

protocol LPPhotoBrowserViewDelegate: class {
    func photoBrowserView(_ browserView: LPPhotoBrowserView,
                          didScrollTo index: Int)
    
    func photoBrowserView(_ browserView: LPPhotoBrowserView,
                          longPressBegin press: UILongPressGestureRecognizer)
    
    func applyHidden(in browserView: LPPhotoBrowserView)
    
    func showBrowerViewWhenEndDragging(in browserView: LPPhotoBrowserView)
    
    func photoBrowserView(_ browserView: LPPhotoBrowserView,
                          changeAlphaWhenDragging alpha: CGFloat)
    func photoBrowserView(_ browserView: LPPhotoBrowserView,
                          willShowBrowerViewWith timeInterval: TimeInterval)
    
}

protocol LPPhotoBrowserViewDataSource: class {
    func numberOfPhotos(in browserView: LPPhotoBrowserView) -> Int
    func photoBrowserView(_ browserView: LPPhotoBrowserView, modelForCellAt index: Int) -> LPPhotoBrowserModel?
}

private let LPCellID = "LPPhotoBrowserCellID"
class LPPhotoBrowserView: UICollectionView {
    weak var pb_delegate: LPPhotoBrowserViewDelegate?
    weak var pb_dataSource: LPPhotoBrowserViewDataSource?
    
    var currentIndex: Int = 0

    //@property (nonatomic, strong) NSString *loadFailedText;
    //@property (nonatomic, strong) NSString *isScaleImageText;
    
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
        
        delegate = self
        dataSource = self
        
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
        
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(deviceOrientationDidChange),
                           name: .UIDeviceOrientationDidChange,
                           object: nil)
    }
    
    func scrollToPageIndex(_ index: Int) {
        let items = collectionView(self, numberOfItemsInSection: 0)
        guard items > index else {
            return log.warning("index is invalid.")
        }
        contentOffset = CGPoint(x: bounds.width * CGFloat(index), y: 0)
    }
    
    @objc private func deviceOrientationDidChange() {
        reloadData()
        layoutIfNeeded()
        scrollToPageIndex(currentIndex)
    }
}

// MARK: - Delegate funcs

extension LPPhotoBrowserView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, LPPhotoBrowserCellDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dataSource = pb_dataSource else { return 0 }
        return dataSource.numberOfPhotos(in: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LPCellID, for: indexPath) as! LPPhotoBrowserCell
        
        guard let dataSource = pb_dataSource
            , let model = dataSource.photoBrowserView(self, modelForCellAt: indexPath.item)
            else { return cell }
        
        cell.delegate = self
        
//    cell.isScaleImageText = self.isScaleImageText;
//    cell.loadFailedText = self.loadFailedText;
       
        cell.bindData(with: model)
        return cell
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indexRatio = scrollView.contentOffset.x / scrollView.bounds.width
        let index = Int(indexRatio + 0.5)
        let numberOfItems = collectionView(self, numberOfItemsInSection: 0)
        guard index < numberOfItems && currentIndex != index else { return }
        
        currentIndex = index
        pb_delegate?.photoBrowserView(self, didScrollTo: index)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let visible = visibleCells as? [LPPhotoBrowserCell] else { return }
        //    for (YBImageBrowserCell *cell in array) {
        //        [cell reDownloadImageUrl];
        //    }
    }
    
    // MARK: - LPPhotoBrowserCellDelegate
    
    func photoBrowserCell(_ cell: LPPhotoBrowserCell, longPressBegin press: UILongPressGestureRecognizer) {
        pb_delegate?.photoBrowserView(self, longPressBegin: press)
    }
    
    func applyHidden(by cell: LPPhotoBrowserCell) {
        pb_delegate?.applyHidden(in: self)
    }
    
    func hideBrowerViewWhenStartDragging(in cell: LPPhotoBrowserCell) {
        guard !isHidden else { return }
        isHidden = true
    }
    
    func showBrowerViewWhenEndDragging(in cell: LPPhotoBrowserCell) {
        pb_delegate?.showBrowerViewWhenEndDragging(in: self)
    }
    
    func photoBrowserCell(_ cell: LPPhotoBrowserCell, changeAlphaWhenDragging alpha: CGFloat) {
        pb_delegate?.photoBrowserView(self, changeAlphaWhenDragging: alpha)
    }
    
    func photoBrowserCell(_ cell: LPPhotoBrowserCell, willShowBrowerViewWith timeInterval: TimeInterval) {
        pb_delegate?.photoBrowserView(self, willShowBrowerViewWith: timeInterval)
    }
}
