//
//  LPPhotoBrowserAnimatedTransitioning.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/5/28.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

protocol LPPhotoBrowserAnimatedDelegate: class {
    
}

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
            case .none: break
                //[self inAnimation_noWithContext:transitionContext];
            case .fade: break
                //[self inAnimation_fadeWithContext:transitionContext containerView:containerView toView:toView];
            case .move:
                inAnimationMove(using: transitionContext,
                                animatingView: animatingView)
            }
        }
        
        /// 出场动效
        else {
            switch LPPhotoBrowserAnimatedOptions.transitionAnimation {
            case .none: break
            //[self outAnimation_noWithContext:transitionContext];
            case .fade: break
            //[self outAnimation_fadeWithContext:transitionContext containerView:containerView fromView:fromView];
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
        
        let toFrame = LPPhotoBrowserCellVM.calculateImage(containerSize: containerView.bounds.size, image: image).imageFrame
        
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
//        let containerView = transitionContext.containerView
//
//        guard let info = showInfoForPresenting, info.image == nil else {
//            return completeTransition(using: transitionContext,
//                                      isPresenting: true,
//                                      iv: nil)
//        }
        
        //    __block CGRect toFrame = CGRectZero;
        //    [YBImageBrowserCell countWithContainerSize:containerView.bounds.size image:image screenOrientation:browser.so_screenOrientation verticalFillType:browser.verticalScreenImageViewFillType horizontalFillType:browser.horizontalScreenImageViewFillType completed:^(CGRect imageFrame, CGSize contentSize, CGFloat minimumZoomScale, CGFloat maximumZoomScale) {
        //        toFrame = imageFrame;
        //    }];
        //
        //    self.animateImageView.image = image;
        //    self.animateImageView.frame = toFrame;
        //    [containerView addSubview:self.animateImageView];
        //    toView.alpha = 0;
        //    self.animateImageView.alpha = 0;
        //    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        //        toView.alpha = 1;
        //        self.animateImageView.alpha = 1;
        //    } completion:^(BOOL finished) {
        //        [self completeTransition:transitionContext isIn:YES];
        //    }];
    }
    
    private func inAnimationNone(using transitionContext: UIViewControllerContextTransitioning, animatingView: UIView) {
        completeTransition(using: transitionContext,
                           isPresenting: true,
                           iv: nil)
    }
}

// MARK: - Private funcs (Out Animation)

extension LPPhotoBrowserAnimatedTransitioning {
    

//- (void)outAnimation_fadeWithContext:(id <UIViewControllerContextTransitioning>)transitionContext containerView:(UIView *)containerView fromView:(UIView *)fromView {
//
//    UIImageView *fromImageView = [self getCurrentImageViewFromBrowser:browser];
//    if (!fromImageView) {
//        [self completeTransition:transitionContext isIn:NO];
//        return;
//    }
//
//    self.animateImageView.image = fromImageView.image;
//    self.animateImageView.frame = [self getFrameInWindowWithView:fromImageView];
//    [containerView addSubview:self.animateImageView];
//
//    fromView.alpha = 1;
//    self.animateImageView.alpha = 1;
//    //因为可能是拖拽动画的视图，索性隐藏掉
//    fromImageView.hidden = YES;
//    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
//        fromView.alpha = 0;
//        self.animateImageView.alpha = 0;
//    } completion:^(BOOL finished) {
//        [self completeTransition:transitionContext isIn:NO];
//    }];
//}
//
    private func outAnimationMove(using transitionContext: UIViewControllerContextTransitioning, animatingView: UIView) {
        let containerView = transitionContext.containerView
        
        guard let info = self.currBrowserInfo
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
            self.completeTransition(using: transitionContext, isPresenting: false, iv: animateIv)
        }
    }

//- (void)outAnimation_noWithContext:(id <UIViewControllerContextTransitioning>)transitionContext {
//    UIImageView *fromImageView = [self getCurrentImageViewFromBrowser:browser];
//    if (fromImageView) fromImageView.hidden = YES;
//    [self completeTransition:transitionContext isIn:NO];
//}
}

// MARK: - Private funcs (Common)

extension LPPhotoBrowserAnimatedTransitioning {
    
    private func completeTransition(using transitionContext: UIViewControllerContextTransitioning,
                                    isPresenting: Bool,
                                    iv: UIImageView?) {
        if let iv = iv {
            isPresenting ? (iv.isHidden = true) : iv.removeFromSuperview()
        }
        
        if isPresenting && !LPPhotoBrowser.isControllerPreferredForStatusBar {
            UIApplication.shared.isStatusBarHidden = LPPhotoBrowser.isHideStatusBar
        }
        
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
        
        let models = delegate.dataModels
        let index = delegate.currentIndex
        if let models = models, models.count > index {
            let model = models[index]
            let frame = frameInWindow(for: model.sourceImageView)
            let image = posterImage(with: model, preview: false)
            
            return (frame, image)
        }
        
        //    } else if (browser.dataSource) {
        //
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
       
        guard let cell = browserView.cellForItem(at: indexPath) as? LPPhotoBrowserCell
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
