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
//                inAnimationNone(using: transitionContext,
//                                animatingView: animatingView)
                break
            case .fade:
//                inAnimationFade(using: transitionContext,
//                                animatingView: animatingView)
                break
            case .move:
                inAnimationMove(using: transitionContext,
                                animatingView: animatingView)
            }
        }
        
        /// 出场动效
        else {
            switch LPPhotoBrowserAnimatedOptions.transitionAnimation {
            case .none:
//                outAnimationNone(using: transitionContext,
//                                 animatingView: animatingView)
                break
            case .fade:
//                outAnimationFade(using: transitionContext,
//                                 animatingView: animatingView)
                break
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
        
        guard let info = inInfo
            , let iv = animateIv(in: containerView, isCreate: true) else {
            return completeTransition(using: transitionContext,
                                      isPresenting: true,
                                      iv: nil)
        }
        
        let image = info.image
        let fromFrame = frameInWindow(for: info.fromIv)
        let toFrame = LPPhotoContainerView.calculateImageSize(containerView.frame.size, image: image)
        
        iv.image = image
        iv.frame = fromFrame
        
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
}

// MARK: - Private funcs (Out Animation)

extension LPPhotoBrowserAnimatedTransitioning {
    
    private func outAnimationMove(using transitionContext: UIViewControllerContextTransitioning, animatingView: UIView) {
        let containerView = transitionContext.containerView
        
        guard let info = outInfo
            , let animateIv = animateIv(in: containerView, isCreate: false) else {
            return completeTransition(using: transitionContext, isPresenting: false, iv: nil)
        }
        
        let image = info.image
        let fromFrame = frameInWindow(for: info.fromIv)
        let toFrame = frameInWindow(for: info.toIv)
        
        animateIv.image = image
        animateIv.frame = fromFrame
        
        animateIv.isHidden = false
        info.fromIv?.isHidden = true
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
}

// MARK: - Private Getter funcs

extension LPPhotoBrowserAnimatedTransitioning {
    
    private var inInfo: (fromIv: UIImageView?, image: UIImage?)? {
        guard let browser = delegate
            , let dataSource = browser.dataSource else { return nil }
        let index = browser.currentIndex
        let type = browser.type
        let source = dataSource.photoBrowser(browser,
                                             sourceAt: index,
                                             of: type)
        let fromIv = dataSource.photoBrowser(browser,
                                             imageViewOfClickedAt: index,
                                             of: type)
        return (fromIv, source?.asImage)
    }
    
    var outInfo: (fromIv: UIImageView?, toIv: UIImageView?, image: UIImage?)? {
        guard let browser = delegate
            , let dataSource = browser.dataSource else { return nil }
        let index = browser.currentIndex
        let type = browser.type
        let toIv = dataSource.photoBrowser(browser,
                                           imageViewOfClickedAt: index,
                                           of: type)
        
        let indexPath = IndexPath(item: index, section: 0)
        guard let cell = browser.browserView.cellForItem(at: indexPath) as? LPPhotoBrowserCell  else { return nil }
        let containerView = cell.containerView
        
        let animateIv: UIImageView
        if containerView.animateImageView.superview == nil {
            animateIv = containerView.imageView
        } else {
            animateIv = containerView.animateImageView
        }
        return (animateIv, toIv, animateIv.image)
    }
}







//    private func inAnimationFade(using transitionContext: UIViewControllerContextTransitioning, animatingView: UIView) {
//        let containerView = transitionContext.containerView
//
//        guard let info = showInfoForPresenting
//            , let image = info.image
//            , let iv = animateIv(in: containerView, isCreate: true) else {
//            return completeTransition(using: transitionContext,
//                                      isPresenting: true,
//                                      iv: nil)
//        }
//
//        let toFrame = LPPhotoBrowser_CellVM.calculateImage(containerSize: containerView.bounds.size, image: image).imageFrame
//
//        iv.image = image
//        iv.frame = toFrame
//
//        animatingView.alpha = 0
//        iv.alpha = 0
//        let duration = transitionDuration(using: transitionContext)
//        UIView.animate(withDuration: duration, animations: {
//            animatingView.alpha = 1
//            iv.alpha = 1
//        }) { [weak self](finished) in
//            self?.completeTransition(using: transitionContext,
//                                     isPresenting: true,
//                                     iv: iv)
//        }
//    }
//
//    private func inAnimationNone(using transitionContext: UIViewControllerContextTransitioning, animatingView: UIView) {
//        completeTransition(using: transitionContext,
//                           isPresenting: true,
//                           iv: nil)
//    }



//    private func outAnimationFade(using transitionContext: UIViewControllerContextTransitioning, animatingView: UIView) {
//        let containerView = transitionContext.containerView
//
//        guard let info = currBrowserInfo
//            , let animateIv = animateIv(in: containerView, isCreate: false) else {
//            return completeTransition(using: transitionContext,
//                                      isPresenting: false,
//                                      iv: nil)
//        }
//
//        let fromIv = info.fromIv
//
//        animateIv.image = fromIv.image
//        animateIv.frame = frameInWindow(for: fromIv)
//
//        animatingView.alpha = 1
//        animateIv.alpha = 1
//
//        fromIv.isHidden = true
//        let duration = transitionDuration(using: transitionContext)
//        UIView.animate(withDuration: duration, animations: {
//            animatingView.alpha = 0
//            animateIv.alpha = 0
//        }) { [weak self](finished) in
//            guard let `self` = self else { return }
//            self.completeTransition(using: transitionContext,
//                                    isPresenting: false,
//                                    iv: animateIv)
//        }
//    }
//
//    private func outAnimationNone(using transitionContext: UIViewControllerContextTransitioning, animatingView: UIView) {
//        currBrowserInfo?.fromIv.isHidden = true
//        completeTransition(using: transitionContext, isPresenting: false, iv: nil)
//    }
