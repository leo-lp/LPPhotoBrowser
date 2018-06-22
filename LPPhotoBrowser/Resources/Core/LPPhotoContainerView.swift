//
//  LPPhotoContainerView.swift
//  LPPhotoBrowser
//
//  Created by 李鹏 on 2018/6/1.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

class LPPhotoContainerView: UIView {
    weak var delegate: LPBrowserCellDelegate?
    
    private(set) var scrollView = UIScrollView()
    private(set) var imageView = UIImageView() // 显示的图片
    private(set) var animateImageView = UIImageView() // 做动画的图片
    
    private(set) var dragAnimate = LPPhotoDragAnimation()
    private(set) var progressView = LPPieProgressView()
        
    deinit {
        #if DEBUG
        print("LPPhotoContainerView: -> release memory.")
        #endif
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupGestures()
        setupNotifications()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        recoverSubviews()
        
        let progressWH: CGFloat = 40.0
        progressView.frame = CGRect(x: (frame.width - progressWH) / 2.0,
                                    y: (frame.height - progressWH) / 2.0,
                                    width: progressWH,
                                    height: progressWH)
    }
    
    func recoverSubviews() {
        scrollView.setZoomScale(1.0, animated: false)
        resizeSubviews()
    }
    
    func bindData(_ source: LPPhotoBrowserSourceConvertible?,
                  delegate: LPBrowserCellDelegate?) {
        self.delegate = delegate
        
        scrollView.setZoomScale(1.0, animated: false)
        
        source?.asImage({ [weak self](percent) in
            guard let `self` = self else { return }
            self.progressView.setProgress(percent, animated: false)
            
            let progress = self.progressView.progress
            let isHidden = progress.isNaN || progress <= 0.0 || progress >= 1.0
            self.progressView.isHidden = isHidden
        }, completion: { [weak self](image) in
            guard let `self` = self else { return }
            
            let shouldResizeSubviews = self.imageView.image?.size != image?.size
            
            if let image = image, let images = image.images {
                self.imageView.image = image
                self.imageView.animationImages = images
                self.imageView.animationDuration = image.duration
                self.imageView.startAnimating()
            } else {
                self.imageView.image = image
            }
            
            if shouldResizeSubviews {
                self.resizeSubviews()
            }
        })
    }
}

// MARK: - Delegate funcs

extension LPPhotoContainerView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let frameSize = scrollView.frame.size
        let contentSize = scrollView.contentSize
        
        let offsetX = (frameSize.width > contentSize.width) ? ((frameSize.width - contentSize.width) * 0.5) : 0.0
        let offsetY = (frameSize.height > contentSize.height) ? ((frameSize.height - contentSize.height) * 0.5) : 0.0
        
        imageView.center = CGPoint(x: contentSize.width * 0.5 + offsetX, y: contentSize.height * 0.5 + offsetY)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.contentInset = .zero
        dragAnimate.isZooming = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dragAnimate.scrollViewDidScroll(scrollView, containerView: self)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dragAnimate.scrollViewWillBeginDragging(scrollView, containerView: self)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        dragAnimate.scrollViewDidEndDragging(scrollView, containerView: self)
    }
}

// MARK: - Private funcs

extension LPPhotoContainerView {
    
    private func setupSubviews() {
        let config = LPPhotoBrowserConfig.shared
        let alwaysBounce = config.isDragAnimationEnabled
        
        scrollView.delegate = self
        scrollView.maximumZoomScale = 2.5
        scrollView.minimumZoomScale = 1.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        
        scrollView.isMultipleTouchEnabled = true
        scrollView.scrollsToTop = false
        scrollView.bouncesZoom = true
        scrollView.delaysContentTouches = true
        scrollView.canCancelContentTouches = true
        
        scrollView.alwaysBounceVertical = alwaysBounce
        scrollView.alwaysBounceHorizontal = alwaysBounce
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        scrollView.frame = bounds
        addSubview(scrollView)
        
        imageView.contentMode = .scaleAspectFill
        scrollView.addSubview(imageView)
        
        animateImageView.contentMode = .scaleAspectFill
        
        progressView.isHidden = true
        addSubview(progressView)
    }
    
    private func setupGestures() {
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(singleTap))
        tap1.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(tap1)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        tap2.numberOfTapsRequired = 2
        tap1.require(toFail: tap2)
        scrollView.addGestureRecognizer(tap2)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture))
        scrollView.addGestureRecognizer(longPress)
    }
    
    private func setupNotifications() {
//        let center = NotificationCenter.default
//        center.addObserver(self,
//                           selector: #selector(deviceOrientationChanged),
//                           name: NSNotification.Name.UIDeviceOrientationDidChange,
//                           object: nil)
    }
    
//    @objc private func deviceOrientationChanged(_ sender: Notification) {
//        if animateImageView.superview != nil {
//            animateImageView.removeFromSuperview()
//        }
//    }
    
    @objc private func singleTap(_ tap: UITapGestureRecognizer) {
        delegate?.imageViewClicked()
    }
    
    @objc private func doubleTap(_ tap: UITapGestureRecognizer) {
        if scrollView.zoomScale > 1.0 {
            scrollView.contentInset = .zero
            scrollView.setZoomScale(1.0, animated: true)
        } else {
            let point = tap.location(in: imageView)
            let newScale = scrollView.maximumZoomScale
            let width = frame.width / newScale
            let height = frame.height / newScale
            let rect = CGRect(x: point.x - width / 2,
                              y: point.y - height / 2,
                              width: width,
                              height: height)
            scrollView.zoom(to: rect, animated: true)
        }
    }
    
    @objc private func longPressGesture(_ press: UILongPressGestureRecognizer) {
        guard press.state == .began else { return }
        delegate?.imageViewLongPressBegin()
    }
    
    private func resizeSubviews() {
        let containerSize = scrollView.frame.size
        let imgFrame = LPPhotoContainerView.calculateImageSize(containerSize, image: imageView.image)
        imageView.frame = imgFrame
        
        let contentSizeH = max(imgFrame.height, frame.height)
        scrollView.contentSize = CGSize(width: containerSize.width,
                                        height: contentSizeH)
        
        scrollView.scrollRectToVisible(bounds, animated: false)
        
        let config = LPPhotoBrowserConfig.shared
        var isEnabled = config.isDragAnimationEnabled
        if isEnabled {
            scrollView.alwaysBounceVertical = isEnabled
            scrollView.alwaysBounceHorizontal = isEnabled
        } else {
            isEnabled = imageView.frame.height > frame.height
            scrollView.alwaysBounceVertical = isEnabled
            scrollView.alwaysBounceHorizontal = false
        }
    }
}

// MARK: - setAsset

//- (void)setAsset:(id)asset {
//    if (_asset && self.imageRequestID) {
//        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
//    }
//    _asset = asset;
//    self.imageRequestID = [[TZImageManager manager] getPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
//        if (![asset isEqual:self->_asset]) return;
//        self.imageView.image = photo;
//        [self resizeSubviews];
//        self->_progressView.hidden = YES;
//        if (self.imageProgressUpdateBlock) {
//            self.imageProgressUpdateBlock(1);
//        }
//        if (!isDegraded) {
//            self.imageRequestID = 0;
//        }
//    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
//        if (![asset isEqual:self->_asset]) return;
//        self->_progressView.hidden = NO;
//        [self bringSubviewToFront:self->_progressView];
//        progress = progress > 0.02 ? progress : 0.02;
//        self->_progressView.progress = progress;
//        if (self.imageProgressUpdateBlock && progress < 1) {
//            self.imageProgressUpdateBlock(progress);
//        }
//
//        if (progress >= 1) {
//            self->_progressView.hidden = YES;
//            self.imageRequestID = 0;
//        }
//    } networkAccessAllowed:YES];
//}

extension LPPhotoContainerView {
    
    static func calculateImageSize(_ containerSize: CGSize, image: UIImage?) -> CGRect {
        let containerW = containerSize.width
        let containerH = containerSize.height
        
        var imageFrame: CGRect = .zero
        imageFrame.size.width = containerW
        
        let imgSize = image?.size ?? .zero
        if imgSize.height / imgSize.width > containerH / containerW {
            let h = floor(imgSize.height / (imgSize.width / containerW))
            imageFrame.size.height = h
        } else {
            var height = imgSize.height / imgSize.width * containerW
            if height < 1 || height.isNaN {
                height = containerH
            }
            height = floor(height)
            
            imageFrame.size.height = height
            imageFrame.origin.y = (containerH - height) / 2
        }
        
        if imageFrame.height > containerH
            && imageFrame.height - containerH <= 1 {
            imageFrame.size.height = containerH
        }
        
        return imageFrame
    }
}
