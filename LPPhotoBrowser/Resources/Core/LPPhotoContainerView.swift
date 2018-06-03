//
//  LPPhotoContainerView.swift
//  LPPhotoBrowser
//
//  Created by 李鹏 on 2018/6/1.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

class LPPhotoContainerView: UIView {
    private(set) var scrollView = UIScrollView()
    private(set) var imageView = UIImageView() // FLAnimatedImageView // 显示的图片
    //private(set) var localImageView = UIImageView() // 用于显示大图的局部图片
    //private(set) var animateImageView = UIImageView() // 做动画的图片
    
    //TZProgressView *progressView;
    
    //@property (nonatomic, strong) id asset;
    //@property (nonatomic, copy) void (^singleTapGestureBlock)(void);
    //@property (nonatomic, copy) void (^imageProgressUpdateBlock)(double progress);
    //@property (nonatomic, assign) int32_t imageRequestID;
    
    var source: LPPhotoBrowserSource? { didSet { bindData() } }
    
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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        
        //    static CGFloat progressWH = 40;
        //    CGFloat progressX = (self.tz_width - progressWH) / 2;
        //    CGFloat progressY = (self.tz_height - progressWH) / 2;
        //    _progressView.frame = CGRectMake(progressX, progressY, progressWH, progressWH)
        recoverSubviews()
    }
    
    func recoverSubviews() {
        scrollView.setZoomScale(1.0, animated: false)
        resizeSubviews()
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
        //vm.isZooming = true
        //[self hideLocalImageView];
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        vm.scrollViewDidScroll(scrollView, cell: self)
//
//    //    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cutImage) object:nil];
//    //    [self performSelector:@selector(cutImage) withObject:nil afterDelay:0.25];
//    }

//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        //[self hideLocalImageView];
//        vm.scrollViewWillBeginDragging(scrollView, cell: self)
//    }
//
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        vm.scrollViewDidEndDragging(scrollView, cell: self)
//    }
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
        //    if (self.singleTapGestureBlock) {
        //        self.singleTapGestureBlock();
        //    }
    }
    
    @objc private func doubleTap(_ tap: UITapGestureRecognizer) {
        //    if (_scrollView.zoomScale > 1.0) {
        //        _scrollView.contentInset = UIEdgeInsetsZero;
        //        [_scrollView setZoomScale:1.0 animated:YES];
        //    } else {
        //        CGPoint touchPoint = [tap locationInView:self.imageView];
        //        CGFloat newZoomScale = _scrollView.maximumZoomScale;
        //        CGFloat xsize = self.frame.size.width / newZoomScale;
        //        CGFloat ysize = self.frame.size.height / newZoomScale;
        //        [_scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
        //    }
    }
    
    private func bindData() {
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
    
    private func resizeSubviews() {
        imageView.frame.origin = .zero
        imageView.frame.size.width = scrollView.frame.width
        
        let imgSize = imageView.image?.size ?? .zero
        if imgSize.height / imgSize.width > frame.height / frame.width {
            imageView.frame.size.height = floor(imgSize.height / (imgSize.width / scrollView.frame.width))
        } else {
            var height = imgSize.height / imgSize.width * scrollView.frame.width
            if height < 1 || height.isNaN {
                height = frame.height
            }
            height = floor(height)
            
            imageView.frame.size.height = height
            imageView.center.y = frame.height / 2
        }
        
        if imageView.frame.height > frame.height
            && imageView.frame.height - frame.height <= 1 {
            imageView.frame.size.height = frame.height
        }
        
        let contentSizeH = max(imageView.frame.height, frame.height)
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width,
                                        height: contentSizeH)
        
        scrollView.scrollRectToVisible(bounds, animated: false)
        
        //scrollView.alwaysBounceVertical = imageView.frame.height <= frame.height ? false : true
    }
}

// MARK: - setAsset

//- (void)setAsset:(id)asset {
//    if (_asset && self.imageRequestID) {
//        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
//    }
//
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
