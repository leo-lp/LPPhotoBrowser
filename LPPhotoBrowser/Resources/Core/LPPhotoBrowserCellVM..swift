//
//  LPPhotoBrowserCellVM..swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/5/30.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

class LPPhotoBrowserCellVM {
    var model: LPPhotoBrowserModel?
    
    var startScaleWidthInAnimationView: CGFloat = 0.0 // 开始拖动时比例
    var startScaleHeightInAnimationView: CGFloat = 0.0 // 开始拖动时比例
    
    var frameOfOriginalOfImageView: CGRect = .zero // 开始拖动时图片frame
    var startOffsetOfScrollView: CGPoint = .zero // 开始拖动时scrollview的偏移
    
    var lastPoint: CGPoint = .zero // 上一次触摸点
    var totalOffsetOfAnimateImageView: CGPoint = .zero // 总共的拖动偏移
    
    var isAnimateFirstTrigger: Bool = false // 拖动动效是否第一次触发
    var isAnimateCancelling: Bool = false // 正在取消拖动动效
    var isZooming: Bool = false // 是否正在释放
    
    //@property (nonatomic, strong) NSString *loadFailedText;
    //@property (nonatomic, strong) NSString *isScaleImageText;
    
    //- (YBImageBrowserProgressBar *)progressBar {
    //    if (!_progressBar) {
    //        _progressBar = [[YBImageBrowserProgressBar alloc] initWithFrame:self.bounds];
    //    }
    //    return _progressBar;
    //}
    
}

//#pragma mark

// MARK: - Drag Animation funcs

extension LPPhotoBrowserCellVM {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView,
                                     cell: LPPhotoBrowserCell) {
        let config = LPPhotoBrowserConfig.shared
        guard !config.cancelDragImageViewAnimation else { return }
        
        let zoomView = cell.imageView
        let currWindow = UIApplication.shared.lp_currWindow
        
        let point = scrollView.panGestureRecognizer.location(in: cell)
        startOffsetOfScrollView = scrollView.contentOffset
        frameOfOriginalOfImageView = zoomView.convert(zoomView.bounds,
                                                      to: currWindow)
        startScaleWidthInAnimationView = (point.x - frameOfOriginalOfImageView.origin.x) / frameOfOriginalOfImageView.width
        startScaleHeightInAnimationView = (point.y - frameOfOriginalOfImageView.origin.y) / frameOfOriginalOfImageView.height
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView,
                             cell: LPPhotoBrowserCell) {
        let config = LPPhotoBrowserConfig.shared
        guard !config.cancelDragImageViewAnimation
            && !isZooming else { return }
        
        let pan = scrollView.panGestureRecognizer
        guard pan.numberOfTouches == 1 else { return }
        
        let animateImageView = cell.animateImageView
        let point = pan.location(in: cell)
        
        let isGreater = point.y > lastPoint.y
        let isLess = scrollView.contentOffset.y < -10
        let isNil = animateImageView.superview == nil
        let shouldAddAnimationView = isGreater && isLess && isNil
        if shouldAddAnimationView {
            addAnimationIv(animateImageView, point: point, cell: cell)
        }
        if pan.state == .changed {
            animate(for: animateImageView, point: point, cell: cell)
        }
        lastPoint = point
    }
    
    private func addAnimationIv(_ iv: UIImageView, point: CGPoint, cell: LPPhotoBrowserCell) {
        let zoomView = cell.imageView
        guard zoomView.frame.width > 0
            && zoomView.frame.height > 0 else { return }
        
        if !LPPhotoBrowser.isControllerPreferredForStatusBar {
            let isStatusBarHidden = UIApplication.shared.isStatusBarHidden
            let isHideBefore = LPPhotoBrowser.isHideStatusBarBefore
            if isStatusBarHidden != isHideBefore {
                UIApplication.shared.isStatusBarHidden = isHideBefore
            }
        }
        
        cell.delegate?.hideBrowerViewWhenStartDragging(in: cell)
        
        isAnimateFirstTrigger = true
        totalOffsetOfAnimateImageView = .zero
        
        iv.image = zoomView.image
        iv.frame = frameOfOriginalOfImageView
        UIApplication.shared.lp_currWindow?.addSubview(iv)
    }
    
    private func animate(for iv: UIImageView, point: CGPoint, cell: LPPhotoBrowserCell) {
        let maxHeight = cell.bounds.height
        guard maxHeight > 0 else { return }
        
        /// 偏移
        var offsetX = point.x - lastPoint.x
        var offsetY = point.y - lastPoint.y
        if isAnimateFirstTrigger {
            offsetX = 0.0
            offsetY = 0.0
            isAnimateFirstTrigger = false
        }
        totalOffsetOfAnimateImageView.x += offsetX
        totalOffsetOfAnimateImageView.y += offsetY
        
        /// 缩放比例
        var scale = (1 - totalOffsetOfAnimateImageView.y / maxHeight)
        if scale > 1 { scale = 1 }
        if scale < 0 { scale = 0 }
        
        /// 执行变换
        let width = frameOfOriginalOfImageView.width * scale
        let height = frameOfOriginalOfImageView.height * scale
        iv.frame = CGRect(x: point.x - width * startScaleWidthInAnimationView,
                          y: point.y - height * startScaleHeightInAnimationView,
                          width: width,
                          height: height)
        cell.delegate?.photoBrowserCell(cell, changeAlphaWhenDragging: scale)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, cell: LPPhotoBrowserCell) {
        isZooming = false
        let animateImageView = cell.animateImageView
        
        guard animateImageView.superview == nil else { return }
        
        let maxHeight = cell.bounds.height
        guard maxHeight > 0 else { return }
        
        if scrollView.zoomScale <= 1 {
            scrollView.contentOffset = .zero
        }
        
        let config = LPPhotoBrowserConfig.shared
        let outScale = config.outScaleOfDragImageViewAnimation
        
        if totalOffsetOfAnimateImageView.y > maxHeight * outScale {
            // 移除图片浏览器
            cell.delegate?.applyHidden(by: cell)
        } else {
            /// 复位
            guard !isAnimateCancelling else { return }
            isAnimateCancelling = true
            
            let duration: TimeInterval = 0.25
            
            cell.delegate?.photoBrowserCell(cell, willShowBrowerViewWith: duration)
            
            UIView.animate(withDuration: duration, animations: {
                animateImageView.frame = self.frameOfOriginalOfImageView
            }) { [weak self](finished) in
                if !LPPhotoBrowser.isControllerPreferredForStatusBar {
                    let isStatusBarHidden = UIApplication.shared.isStatusBarHidden
                    let isHide = LPPhotoBrowser.isHideStatusBar
                    if isStatusBarHidden != isHide {
                        UIApplication.shared.isStatusBarHidden = isHide
                    }
                }
                
                guard let `self` = self else { return }
                scrollView.contentOffset = self.startOffsetOfScrollView
                
                cell.delegate?.showBrowerViewWhenEndDragging(in: cell)
                
                animateImageView.removeFromSuperview()
                self.isAnimateCancelling = false
            }
        }
    }
}

extension LPPhotoBrowserCellVM {
    
    /// 计算图片大小
    typealias LPCalculateResult =
        (imageFrame: CGRect,
        contentSize: CGSize,
        minimumZoomScale: CGFloat,
        maximumZoomScale: CGFloat)
    static func calculateImage(containerSize: CGSize, image: UIImage) -> LPCalculateResult {
        //    CGSize imageSize = [FLAnimatedImage sizeForImage:image];
        let imageSize = image.size
        let containerWidth = containerSize.width
        let containerHeight = containerSize.height
        let containerScale = containerWidth / containerHeight
        
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        var minimumZoomScale: CGFloat = 1.0
        var maximumZoomScale: CGFloat = 1.0
        
        var contentSize: CGSize = .zero
        
        /// 计算最大缩放比例
        let widthScale = imageSize.width / containerWidth
        let heightScale = imageSize.height / containerHeight
        let maxScale = widthScale > heightScale ? widthScale : heightScale
        
        maximumZoomScale = maxScale > 1.0 ? maxScale : 1.0
        
        let config = LPPhotoBrowserConfig.shared
        
        let fillType: LPPhotoBrowserViewFillType
        if UIApplication.shared.isOrientationVertical {
            fillType = config.verticalScreenImageViewFillType
        } else {
            fillType = config.horizontalScreenImageViewFillType
        }
        
        switch fillType {
        case .fullWidth:
            width = containerWidth
            height = containerWidth * (imageSize.height / imageSize.width)
            if imageSize.width / imageSize.height >= containerScale {
                x = 0
                y = (containerHeight - height) / 2.0
                contentSize = CGSize(width: containerWidth,
                                     height: containerHeight)
                minimumZoomScale = 1
            } else {
                x = 0
                y = 0
                contentSize = CGSize(width: containerWidth,
                                     height: height)
                minimumZoomScale = containerHeight / height
            }
        case .completely:
            if imageSize.width / imageSize.height >= containerScale {
                width = containerWidth
                height = containerWidth * (imageSize.height / imageSize.width)
                x = 0
                y = (containerHeight - height) / 2.0
            } else {
                height = containerHeight
                width = containerHeight * (imageSize.width / imageSize.height)
                x = (containerWidth - width) / 2.0
                y = 0
            }
            contentSize = CGSize(width: containerWidth,
                                 height: containerHeight)
            minimumZoomScale = 1
        }
        
        let frame = CGRect(x: x, y: y, width: width, height: height)
        return (frame, contentSize, minimumZoomScale, maximumZoomScale)
    }
}
