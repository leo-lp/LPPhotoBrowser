//
//  LPPhotoBrowserView.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/5/29.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

protocol LPPhotoBrowserViewDelegate: class {
    //- (void)yBImageBrowserView:(YBImageBrowserView *)imageBrowserView didScrollToIndex:(NSUInteger)index;
    //
    //- (void)yBImageBrowserView:(YBImageBrowserView *)imageBrowserView longPressBegin:(UILongPressGestureRecognizer *)gesture;
    
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
    
    //@interface YBImageBrowserView : UICollectionView <YBImageBrowserScreenOrientationProtocol>
    
    weak var pb_delegate: LPPhotoBrowserViewDelegate?
    weak var pb_dataSource: LPPhotoBrowserViewDataSource?
    
    var currentIndex: Int = 0

    //@property (nonatomic, assign) YBImageBrowserImageViewFillType verticalScreenImageViewFillType;
    //@property (nonatomic, assign) YBImageBrowserImageViewFillType horizontalScreenImageViewFillType;
    //@property (nonatomic, strong) NSString *loadFailedText;
    //@property (nonatomic, strong) NSString *isScaleImageText;
    //@property (nonatomic, assign) BOOL autoCountMaximumZoomScale;
    //
    //@interface YBImageBrowserView ()
    //@end
    //
    //@implementation YBImageBrowserView
    //
    //@synthesize so_screenOrientation = _so_screenOrientation;
    //@synthesize so_frameOfVertical = _so_frameOfVertical;
    //@synthesize so_frameOfHorizontal = _so_frameOfHorizontal;
    //@synthesize so_isUpdateUICompletely = _so_isUpdateUICompletely;
    
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
    }
    
    func scrollToPageIndex(_ index: Int) {
        let items = collectionView(self, numberOfItemsInSection: 0)
        guard items > index else {
            return log.warning("index is invalid.")
        }
        contentOffset = CGPoint(x: bounds.width * CGFloat(index), y: 0)
    }
}

//
//#pragma mark YBImageBrowserScreenOrientationProtocol
//
//- (void)so_setFrameInfoWithSuperViewScreenOrientation:(YBImageBrowserScreenOrientation)screenOrientation superViewSize:(CGSize)size {
//
//    BOOL isVertical = screenOrientation == YBImageBrowserScreenOrientationVertical;
//    CGRect rect0 = CGRectMake(0, 0, size.width, size.height), rect1 = CGRectMake(0, 0, size.height, size.width);
//    _so_frameOfVertical = isVertical ? rect0 : rect1;
//    _so_frameOfHorizontal = !isVertical ? rect0 : rect1;
//}
//
//- (void)so_updateFrameWithScreenOrientation:(YBImageBrowserScreenOrientation)screenOrientation {
//    if (screenOrientation == _so_screenOrientation) return;
//
//    _so_isUpdateUICompletely = NO;
//
//    self.frame = screenOrientation == YBImageBrowserScreenOrientationVertical ? _so_frameOfVertical : _so_frameOfHorizontal;
//
//    _so_screenOrientation = screenOrientation;
//
//    [self reloadData];
//    [self layoutIfNeeded];
//    [self scrollToPageWithIndex:self.currentIndex];
//
//    _so_isUpdateUICompletely = YES;
//}

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
//    cell.verticalScreenImageViewFillType = self.verticalScreenImageViewFillType;
//    cell.horizontalScreenImageViewFillType = self.horizontalScreenImageViewFillType;
//    cell.autoCountMaximumZoomScale = self.autoCountMaximumZoomScale;
//    [cell so_updateFrameWithScreenOrientation:_so_screenOrientation];
       
        cell.bindData(with: model)
        return cell
    }
    
    // MARK: - UIScrollViewDelegate
    
    //- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //    CGFloat indexF = (scrollView.contentOffset.x / scrollView.bounds.size.width);
    //    NSUInteger index = (NSUInteger)(indexF + 0.5);
    //    if (index > [self collectionView:self numberOfItemsInSection:0]) return;
    //    if (self.currentIndex != index && _so_isUpdateUICompletely) {
    //        self.currentIndex = index;
    //        if (_yb_delegate && [_yb_delegate respondsToSelector:@selector(yBImageBrowserView:didScrollToIndex:)]) {
    //            [_yb_delegate yBImageBrowserView:self didScrollToIndex:self.currentIndex];
    //        }
    //    }
    //}
    //- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //    NSArray<YBImageBrowserCell *>* array = (NSArray<YBImageBrowserCell *>*)[self visibleCells];
    //    for (YBImageBrowserCell *cell in array) {
    //        [cell reDownloadImageUrl];
    //    }
    //}
    
    // MARK: - LPPhotoBrowserCellDelegate
    
    func photoBrowserCell(_ cell: LPPhotoBrowserCell, longPressBegin: UILongPressGestureRecognizer) {
        //    if (_yb_delegate && [_yb_delegate respondsToSelector:@selector(yBImageBrowserView:longPressBegin:)]) {
        //        [_yb_delegate yBImageBrowserView:self longPressBegin:gesture];
        //    }
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

// MARK: - Private funcs

extension LPPhotoBrowserView {
    
}
