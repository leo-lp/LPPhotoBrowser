//
//  LPPhotoBrowserAnimatedTransitioning.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/5/28.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

protocol LPPhotoBrowserAnimatedDelegate: class { }

class LPPhotoBrowserAnimatedTransitioning: NSObject {
    private weak var delegate: (LPPhotoBrowser & LPPhotoBrowserAnimatedDelegate)?
    
    deinit {
        log.warning("release memory.")
    }
    
    init(delegate: (LPPhotoBrowser & LPPhotoBrowserAnimatedDelegate)) {
        super.init()
        self.delegate = delegate
    }
}

// MARK: - Delegate

extension LPPhotoBrowserAnimatedTransitioning: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return LPPhotoBrowserAnimatedOptions.transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from)
        let toVC = transitionContext.viewController(forKey: .to)
        
        let isPresenting: Bool = (toVC?.presentingViewController == fromVC)
        
        guard let animatingVC = isPresenting ? toVC : fromVC
            , let animatingView = animatingVC.view else { return }
        
        /// 入场动效
        if isPresenting {
            transitionContext.containerView.addSubview(animatingView)
            switch LPPhotoBrowserAnimatedOptions.transitionAnimation {
            case .none:
                inAnimationNone(using: transitionContext,
                                animatingView: animatingView)
            case .fade:
                inAnimationFade(using: transitionContext,
                                animatingView: animatingView)
            case .move:
                inAnimationMove(using: transitionContext,
                                animatingView: animatingView)
            }
        }
        
        /// 出场动效
        else {
            switch LPPhotoBrowserAnimatedOptions.transitionAnimation {
            case .none:
                outAnimationNone(using: transitionContext,
                                 animatingView: animatingView)
            case .fade:
                outAnimationFade(using: transitionContext,
                                 animatingView: animatingView)
            case .move:
                outAnimationMove(using: transitionContext,
                                 animatingView: animatingView)
            }
        }
    }
}

// MARK: - Private funcs (In Animation)

extension LPPhotoBrowserAnimatedTransitioning {
    
    private func inAnimationMove(using transitionContext: UIViewControllerContextTransitioning, animatingView: UIView) {
        let containerView = transitionContext.containerView
        
        guard let info = showInfoForPresenting
            , let image = info.image
            , let iv = animateIv(in: containerView, isCreate: true) else {
            return completeTransition(using: transitionContext,
                                      isPresenting: true,
                                      iv: nil)
        }
        
        let toFrame = LPPhotoBrowser_CellVM.calculateImage(containerSize: containerView.bounds.size, image: image).imageFrame
        
        iv.image = image
        iv.frame = info.fromFrame
        
        animatingView.alpha = 0
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            animatingView.alpha = 1
            iv.frame = toFrame
        }) { [weak self](finished) in
            self?.completeTransition(using: transitionContext,
                                     isPresenting: true,
                                     iv: iv)
        }
    }
    
    private func inAnimationFade(using transitionContext: UIViewControllerContextTransitioning, animatingView: UIView) {
        let containerView = transitionContext.containerView
        
        guard let info = showInfoForPresenting
            , let image = info.image
            , let iv = animateIv(in: containerView, isCreate: true) else {
            return completeTransition(using: transitionContext,
                                      isPresenting: true,
                                      iv: nil)
        }
        
        let toFrame = LPPhotoBrowser_CellVM.calculateImage(containerSize: containerView.bounds.size, image: image).imageFrame
        
        iv.image = image
        iv.frame = toFrame
        
        animatingView.alpha = 0
        iv.alpha = 0
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            animatingView.alpha = 1
            iv.alpha = 1
        }) { [weak self](finished) in
            self?.completeTransition(using: transitionContext,
                                     isPresenting: true,
                                     iv: iv)
        }
    }
    
    private func inAnimationNone(using transitionContext: UIViewControllerContextTransitioning, animatingView: UIView) {
        completeTransition(using: transitionContext,
                           isPresenting: true,
                           iv: nil)
    }
}

// MARK: - Private funcs (Out Animation)

extension LPPhotoBrowserAnimatedTransitioning {
    
    private func outAnimationMove(using transitionContext: UIViewControllerContextTransitioning, animatingView: UIView) {
        let containerView = transitionContext.containerView
        
        guard let info = currBrowserInfo
            , let animateIv = animateIv(in: containerView, isCreate: false) else {
            return completeTransition(using: transitionContext, isPresenting: false, iv: nil)
        }
        
        let toFrame = frameInWindow(for: info.model.sourceImageView)
        
        let fromIv = info.fromIv
        animateIv.image = fromIv.image
        animateIv.frame = frameInWindow(for: fromIv)
        
        animateIv.isHidden = false
        fromIv.isHidden = true
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            animatingView.alpha = 0
            animateIv.frame = toFrame
        }) { [weak self](finished) in
            guard let `self` = self else { return }
            self.completeTransition(using: transitionContext,
                                    isPresenting: false,
                                    iv: animateIv)
        }
    }
    
    private func outAnimationFade(using transitionContext: UIViewControllerContextTransitioning, animatingView: UIView) {
        let containerView = transitionContext.containerView
        
        guard let info = currBrowserInfo
            , let animateIv = animateIv(in: containerView, isCreate: false) else {
            return completeTransition(using: transitionContext,
                                      isPresenting: false,
                                      iv: nil)
        }
        
        let fromIv = info.fromIv
        
        animateIv.image = fromIv.image
        animateIv.frame = frameInWindow(for: fromIv)
        
        animatingView.alpha = 1
        animateIv.alpha = 1
        
        fromIv.isHidden = true
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            animatingView.alpha = 0
            animateIv.alpha = 0
        }) { [weak self](finished) in
            guard let `self` = self else { return }
            self.completeTransition(using: transitionContext,
                                    isPresenting: false,
                                    iv: animateIv)
        }
    }
    
    private func outAnimationNone(using transitionContext: UIViewControllerContextTransitioning, animatingView: UIView) {
        currBrowserInfo?.fromIv.isHidden = true
        completeTransition(using: transitionContext, isPresenting: false, iv: nil)
    }
}

// MARK: - Private funcs (Common)

extension LPPhotoBrowserAnimatedTransitioning {
    
    private func completeTransition(using transitionContext: UIViewControllerContextTransitioning,
                                    isPresenting: Bool,
                                    iv: UIImageView?) {
        if let iv = iv {
            isPresenting ? (iv.isHidden = true) : iv.removeFromSuperview()
        }
//        
//        if isPresenting && !LPPhotoBrowser.isControllerPreferredForStatusBar {
//            UIApplication.shared.isStatusBarHidden = LPPhotoBrowser.isHideStatusBar
//        }
        
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
    
    private func animateIv(in containerView: UIView, isCreate: Bool) -> UIImageView? {
        let tag: Int = 1234321
        if let iv = containerView.viewWithTag(tag) as? UIImageView {
            return iv
        }
        
        guard isCreate else { return nil }
        
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.tag = tag
        containerView.addSubview(iv)
        return iv
    }
    
    /// 获取view在window中的frame
    private func frameInWindow(for view: UIView?) -> CGRect {
        guard let view = view else { return .zero }
        return view.convert(view.bounds,
                            to: UIApplication.shared.lp_currWindow)
    }
    
    /// 获取入场动画的image
    private func posterImage(with model: LPPhotoBrowserModel,
                             preview: Bool) -> UIImage? {
        if !preview
            , let sourceIv = model.sourceImageView
            , let image = sourceIv.image {
            return image
        }
        
        if let image = model.image {
            return image
        }
        
        //    if (model.animatedImage) {
        //        return model.animatedImage.posterImage ?: nil;
        //    } else {
        //        if (!preview && model.previewModel) {
        //            return [self in_getPosterImageWithModel:model preview:YES];
        //        } else {
        //            return nil;
        //        }
        //    }
        return nil
    }
}

// MARK: - Private Getter funcs

extension LPPhotoBrowserAnimatedTransitioning {
    /// 从图片浏览器拿到初始化过后首先显示的数据
    private var showInfoForPresenting: (fromFrame: CGRect, image: UIImage?)? {
        guard let delegate = delegate else { return nil }
        
//        let models = delegate.dataModels
//        let index = delegate.currentIndex
//        if let models = models, models.count > index {
//            let model = models[index]
//            let frame = frameInWindow(for: model.sourceImageView)
//            let image = posterImage(with: model, preview: false)
//            
//            return (frame, image)
//        }
        //    } else if (browser.dataSource) {
        //        //用户使用了数据源代理
        //        UIImageView *tempImageView = [browser.dataSource respondsToSelector:@selector(imageViewOfTouchForImageBrowser:)] ? [browser.dataSource imageViewOfTouchForImageBrowser:browser] : nil;
        //        _fromFrame = tempImageView ? [self getFrameInWindowWithView:tempImageView] : CGRectZero;
        //        _fromImage = tempImageView.image;
        //
        //    } else {
        //        YBLOG_ERROR(@"you must perform selector(setDataArray:) or implementation protocol(dataSource) of YBImageBrowser to configuration data For user interface");
        //        return NO;
        //    }
        return nil
    }
    
    /// 从图片浏览器获取当前显示的Model和animateIv信息
    var currBrowserInfo: (model: LPPhotoBrowserModel, fromIv: UIImageView)? {
        guard let delegate = delegate else { return nil }
        let currentIndex = delegate.currentIndex
        let indexPath = IndexPath(item: currentIndex, section: 0)
        let browserView = delegate.browserView
       
        guard let cell = browserView.cellForItem(at: indexPath) as? LPPhotoBrowser_Cell
            , let model = cell.vm.model else { return nil }
        
        let browserAnimateIv = cell.animateImageView
        let animateIv: UIImageView
        if browserAnimateIv.superview == nil {
            animateIv = cell.imageView
        } else {
            animateIv = browserAnimateIv
        }
        return (model, animateIv)
    }
}
