//
//  LPPhotoDragAnimation.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/6/4.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

class LPPhotoDragAnimation {
    var startScaleSizeInAnimationView: CGSize = .zero // 开始拖动时比例
    
    var frameOfOriginalImageView: CGRect = .zero // 开始拖动时图片frame
    var startOffsetOfScrollView: CGPoint = .zero // 开始拖动时scrollview的偏移
    
    var lastPoint: CGPoint = .zero // 上一次触摸点
    var totalOffsetOfAnimateImageView: CGPoint = .zero // 总共的拖动偏移
    
    var isAnimateFirstTrigger: Bool = false // 拖动动效是否第一次触发
    var isAnimateCancelling: Bool = false // 正在取消拖动动效
    var isZooming: Bool = false // 是否正在释放
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView,
                                     containerView: LPPhotoContainerView) {
        let config = LPPhotoBrowserConfig.shared
        guard !config.cancelDragImageViewAnimation else { return }
        
        let zoomView = containerView.imageView
        let currWindow = UIApplication.shared.lp_currWindow
        
        let point = scrollView.panGestureRecognizer.location(in: containerView)
        startOffsetOfScrollView = scrollView.contentOffset
        frameOfOriginalImageView = zoomView.convert(zoomView.bounds,
                                                      to: currWindow)
        
        let w = (point.x - frameOfOriginalImageView.origin.x) / frameOfOriginalImageView.width
        let h = (point.y - frameOfOriginalImageView.origin.y) / frameOfOriginalImageView.height
        startScaleSizeInAnimationView = CGSize(width: w, height: h)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView,
                             containerView: LPPhotoContainerView) {
        let config = LPPhotoBrowserConfig.shared
        guard !config.cancelDragImageViewAnimation
            && !isZooming else { return }
        
        let pan = scrollView.panGestureRecognizer
        guard pan.numberOfTouches == 1 else { return }
        
        let animateImageView = containerView.animateImageView
        let point = pan.location(in: containerView)
        
        let isGreater = point.y > lastPoint.y
        let isLess = scrollView.contentOffset.y < -10
        let isNil = animateImageView.superview == nil
        let shouldAddAnimationView = isGreater && isLess && isNil
        if shouldAddAnimationView {
            addAnimationIv(animateImageView,
                           point: point,
                           containerView: containerView)
        }
        if pan.state == .changed {
            animate(for: animateImageView,
                    point: point,
                    containerView: containerView)
        }
        lastPoint = point
    }
    
    private func addAnimationIv(_ iv: UIImageView,
                                point: CGPoint,
                                containerView: LPPhotoContainerView) {
        let zoomView = containerView.imageView
        guard zoomView.frame.width > 0
            && zoomView.frame.height > 0 else { return }
        
        //        if !LPPhotoBrowser.isControllerPreferredForStatusBar {
        //            let isStatusBarHidden = UIApplication.shared.isStatusBarHidden
        //            let isHideBefore = LPPhotoBrowser.isHideStatusBarBefore
        //            if isStatusBarHidden != isHideBefore {
        //                UIApplication.shared.isStatusBarHidden = isHideBefore
        //            }
        //        }
        
        containerView.delegate?.hideWhenStartDragging()
        
        isAnimateFirstTrigger = true
        totalOffsetOfAnimateImageView = .zero
        
        iv.image = zoomView.image
        iv.frame = frameOfOriginalImageView
        UIApplication.shared.lp_currWindow?.addSubview(iv)
    }
    
    private func animate(for iv: UIImageView,
                         point: CGPoint,
                         containerView: LPPhotoContainerView) {
        let maxHeight = containerView.bounds.height
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
        let width = frameOfOriginalImageView.width * scale
        let height = frameOfOriginalImageView.height * scale
        iv.frame = CGRect(x: point.x - width * startScaleSizeInAnimationView.width,
                          y: point.y - height * startScaleSizeInAnimationView.height,
                          width: width,
                          height: height)
        containerView.delegate?.changeAlphaWhenDragging(scale)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  containerView: LPPhotoContainerView) {
        isZooming = false
        let animateImageView = containerView.animateImageView
        
        guard animateImageView.superview != nil else { return }
        
        let maxHeight = containerView.bounds.height
        guard maxHeight > 0 else { return }
        
        if scrollView.zoomScale <= 1 {
            scrollView.contentOffset = .zero
        }
        
        let config = LPPhotoBrowserConfig.shared
        let outScale = config.outScaleOfDragImageViewAnimation
        
        if totalOffsetOfAnimateImageView.y > maxHeight * outScale {
            // 移除图片浏览器
            containerView.delegate?.dismissWhenEndDragging()
        } else {
            /// 复位
            guard !isAnimateCancelling else { return }
            isAnimateCancelling = true
            
            let duration: TimeInterval = 0.25
            
            containerView.delegate?.show(with: duration)
            
            UIView.animate(withDuration: duration, animations: {
                animateImageView.frame = self.frameOfOriginalImageView
            }) { [weak self](finished) in
                //                if !LPPhotoBrowser.isControllerPreferredForStatusBar {
                //                    let isStatusBarHidden = UIApplication.shared.isStatusBarHidden
                //                    let isHide = LPPhotoBrowser.isHideStatusBar
                //                    if isStatusBarHidden != isHide {
                //                        UIApplication.shared.isStatusBarHidden = isHide
                //                    }
                //                }
                
                guard let `self` = self else { return }
                scrollView.contentOffset = self.startOffsetOfScrollView
                
                containerView.delegate?.showWhenEndDragging()
                
                animateImageView.removeFromSuperview()
                self.isAnimateCancelling = false
            }
        }
    }
}
