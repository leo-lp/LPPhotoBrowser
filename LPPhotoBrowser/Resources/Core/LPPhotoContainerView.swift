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
    private(set) var imageView = UIImageView() // FLAnimatedImageView // 显示的图片
    //private(set) var localImageView = UIImageView() // 用于显示大图的局部图片
    private(set) var animateImageView = UIImageView() // 做动画的图片
    
    private(set) var dragAnimate = LPPhotoDragAnimation()
    
    //TZProgressView *progressView;
    //id asset;
    //void (^singleTapGestureBlock)(void);
    //void (^imageProgressUpdateBlock)(double progress);
    //int32_t imageRequestID;
        
    deinit {
        log.warning("release memory.")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupGestures()
        
        scrollView.layer.borderColor = UIColor.green.cgColor
        scrollView.layer.borderWidth = 2
        
        imageView.layer.borderColor = UIColor.magenta.cgColor
        imageView.layer.borderWidth = 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        
        //static CGFloat progressWH = 40;
        //CGFloat progressX = (self.tz_width - progressWH) / 2;
        //CGFloat progressY = (self.tz_height - progressWH) / 2;
        //progressView.frame = CGRectMake(progressX, progressY, progressWH, progressWH)
        recoverSubviews()
    }
    
    func recoverSubviews() {
        scrollView.setZoomScale(1.0, animated: false)
        resizeSubviews()
    }
    
    func bindData(_ source: LPPhotoBrowserSource?,
                  delegate: LPBrowserCellDelegate?) {
        self.delegate = delegate
        
        scrollView.setZoomScale(1.0, animated: false)
        
        guard let source = source else { return }
        switch source {
        case .image(let image): imageView.image = image
        case .URL(let placeholder, let thumbnail, let original):
            imageView.image = placeholder
        }
        
        //    if (model.type == TZAssetModelMediaTypePhotoGif) {
        //        // 先显示缩略图
        //        [[TZImageManager manager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        //            self.imageView.image = photo;
        //            [self resizeSubviews];
        //            // 再显示gif动图
        //            [[TZImageManager manager] getOriginalPhotoDataWithAsset:model.asset completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
        //                if (!isDegraded) {
        //                    self.imageView.image = [UIImage sd_tz_animatedGIFWithData:data];
        //                    [self resizeSubviews];
        //                }
        //            }];
        //        } progressHandler:nil networkAccessAllowed:NO];
        //    } else {
        //        self.asset = model.asset;
        //    }
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
        
        imageView.center = CGPoint(x: contentSize.width * 0.5 + offsetX,
                                   y: contentSize.height * 0.5 + offsetY)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.contentInset = .zero
        dragAnimate.isZooming = true
        //[self hideLocalImageView];
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dragAnimate.scrollViewDidScroll(scrollView,
                                        containerView: self)
        //    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cutImage) object:nil];
        //    [self performSelector:@selector(cutImage) withObject:nil afterDelay:0.25];
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //[self hideLocalImageView];
        dragAnimate.scrollViewWillBeginDragging(scrollView,
                                                containerView: self)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool) {
        dragAnimate.scrollViewDidEndDragging(scrollView,
                                             containerView: self)
    }
}

// MARK: - Private funcs

extension LPPhotoContainerView {
    
    private func setupSubviews() {
        let config = LPPhotoBrowserConfig.shared
        let alwaysBounce = !config.cancelDragImageViewAnimation
        
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
        
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        scrollView.addSubview(imageView)
        
        //animateImageView.contentMode = .scaleAspectFill
        //animateImageView.layer.masksToBounds = true

        //localImageView.contentMode = .scaleAspectFill
        //localImageView.isHidden = true
        //addSubview(localImageView)
        
        //[self configProgressView];
        //- (void)configProgressView {
        //    _progressView = [[TZProgressView alloc] init];
        //    _progressView.hidden = YES;
        //    [self addSubview:_progressView];
        //}
    }
    
    private func setupGestures() {
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(singleTap))
        tap1.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(tap1)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        tap2.numberOfTapsRequired = 2
        tap1.require(toFail: tap2)
        scrollView.addGestureRecognizer(tap2)
        //let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture))
        //scrollView.addGestureRecognizer(longPress)
    }
    
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
    
    private func resizeSubviews() {
        let containerSize = scrollView.frame.size
        let imgFrame = LPPhotoContainerView.calculateImageSize(containerSize, image: imageView.image)
        imageView.frame = imgFrame
        
        let contentSizeH = max(imgFrame.height, frame.height)
        scrollView.contentSize = CGSize(width: containerSize.width,
                                        height: contentSizeH)
        
        scrollView.scrollRectToVisible(bounds, animated: false)
        
        let config = LPPhotoBrowserConfig.shared
        let cancelDrag = config.cancelDragImageViewAnimation
        if cancelDrag {
            scrollView.alwaysBounceVertical = imageView.frame.height > frame.height
            scrollView.alwaysBounceHorizontal = false
        } else {
            scrollView.alwaysBounceVertical = true
            scrollView.alwaysBounceHorizontal = true
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
