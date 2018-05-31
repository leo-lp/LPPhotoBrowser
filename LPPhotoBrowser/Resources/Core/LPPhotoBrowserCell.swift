//
//  LPPhotoBrowserCell.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/5/29.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

protocol LPPhotoBrowserCellDelegate: class {
    func photoBrowserCell(_ cell: LPPhotoBrowserCell, longPressBegin press: UILongPressGestureRecognizer)
    func applyHidden(by cell: LPPhotoBrowserCell)
    
    func hideBrowerViewWhenStartDragging(in cell: LPPhotoBrowserCell)
    func showBrowerViewWhenEndDragging(in cell: LPPhotoBrowserCell)
    func photoBrowserCell(_ cell: LPPhotoBrowserCell, changeAlphaWhenDragging alpha: CGFloat)
    func photoBrowserCell(_ cell: LPPhotoBrowserCell, willShowBrowerViewWith timeInterval: TimeInterval)
}

class LPPhotoBrowserCell: UICollectionViewCell {
    // MARK: - Public Propertys
    
    weak var delegate: LPPhotoBrowserCellDelegate?
    
    
    
    // MARK: - Private Propertys
    
    private(set) var scrollView = UIScrollView()
    private(set) var animateImageView = UIImageView() // 做动画的图片
    private(set) var imageView = UIImageView() // FLAnimatedImageView // 显示的图片
    private(set) var localImageView = UIImageView() // 用于显示大图的局部图片
    
    private(set) var vm = LPPhotoBrowserCellVM()
    
    // MARK: - Override funcs
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        log.warning("release memory.")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderColor = UIColor.blue.cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 2
        
        imageView.layer.borderColor = UIColor.yellow.cgColor
        imageView.layer.borderWidth = 2
        
        localImageView.layer.borderColor = UIColor.green.cgColor
        localImageView.layer.borderWidth = 2
        
        setupSubviews()
        addGestures()
        addNotifications()
        
        contentView.addSubview(scrollView)
        scrollView.addSubview(imageView)
        addSubview(localImageView)
    }
    
    override func prepareForReuse() {
        scrollView.setZoomScale(1.0, animated: false)
        
        imageView.image = nil
        imageView.animationImages = nil
        
        //    if (self.progressBar.superview) {
        //        [self.progressBar removeFromSuperview];
        //    }
        //    [self hideLocalImageView];
        
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.setZoomScale(1, animated: true)
        
        scrollView.frame = bounds
        scrollView.contentSize = bounds.size
        //self.progressBar.frame = self.bounds
        
        print("scrollView.frame=\(scrollView.frame)")
    }
}

// MARK: - Public funcs

extension LPPhotoBrowserCell {
    
    func bindData(with model: LPPhotoBrowserModel) {
        vm.model = model
        loadImage(with: model, isPreview: false)
    }
    
//- (void)reDownloadImageUrl {
//    if ([[self.model valueForKey:YBImageBrowserModel_KVCKey_isLoadFailed] boolValue] && ![[self.model valueForKey:YBImageBrowserModel_KVCKey_isLoading] boolValue]) {
//        [self downLoadImageWithModel:self.model];
//    }
//}
}

// MARK: - Delegate funcs

extension LPPhotoBrowserCell: UIScrollViewDelegate {
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        var frame = imageView.frame
        let scrollViewHeight = scrollView.bounds.height
        let scrollViewWidth = scrollView.bounds.width
        if frame.height > scrollViewHeight {
            frame.origin.y = 0
        } else {
            frame.origin.y = (scrollViewHeight - frame.height) / 2.0
        }
        if frame.width > scrollViewWidth {
            frame.origin.x = 0
        } else {
            frame.origin.x = (scrollViewWidth - frame.width) / 2.0
        }
        imageView.frame = frame
        print("1.imageView.frame=\(imageView.frame)")
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    vm.scrollViewDidScroll(scrollView, cell: self)
    
    //    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cutImage) object:nil];
    //    [self performSelector:@selector(cutImage) withObject:nil afterDelay:0.25];
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        vm.isZooming = true
        //[self hideLocalImageView];
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //[self hideLocalImageView];
        vm.scrollViewWillBeginDragging(scrollView, cell: self)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        vm.scrollViewDidEndDragging(scrollView, cell: self)
    }
}

// MARK: - Private funcs

extension LPPhotoBrowserCell {
    
    private func setupSubviews() {
        let config = LPPhotoBrowserConfig.shared
        let alwaysBounce = !config.cancelDragImageViewAnimation
        
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        scrollView.maximumZoomScale = 1
        scrollView.minimumZoomScale = 1
        scrollView.alwaysBounceVertical = alwaysBounce
        scrollView.alwaysBounceHorizontal = alwaysBounce
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        scrollView.frame = bounds
        scrollView.contentSize = bounds.size
        
        animateImageView.contentMode = .scaleAspectFill
        animateImageView.layer.masksToBounds = true
        
        imageView.contentMode = .scaleAspectFit
        
        localImageView.contentMode = .scaleAspectFill
        localImageView.isHidden = true
    }
    
    private func addGestures() {
        let single = UITapGestureRecognizer(target: self, action: #selector(singleGesture))
        single.numberOfTapsRequired = 1
        let double = UITapGestureRecognizer(target: self, action: #selector(doubleGesture))
        double.numberOfTapsRequired = 2
        single.require(toFail: double)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture))
        scrollView.addGestureRecognizer(single)
        scrollView.addGestureRecognizer(double)
        scrollView.addGestureRecognizer(longPress)
    }
    
    private func addNotifications() {
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(deviceOrientationDidChange),
                           name: .UIDeviceOrientationDidChange,
                           object: nil)
    }
    
    @objc private func deviceOrientationDidChange() {
        guard animateImageView.superview != nil else { return }
        animateImageView.removeFromSuperview()
    }
    
    private func loadImage(with model: LPPhotoBrowserModel, isPreview: Bool) {
        if let image = model.image {
            // 若是压缩过后的图片，用原图计算缩放比例
            if model.needCutToShow {
                //[self countLayoutWithImage:[model valueForKey:YBImageBrowserModel_KVCKey_largeImage] completed:nil];
            } else {
                calculateLayout(model, image: image)
            }
            imageView.image = image
        } else if model.needCutToShow {
            //        //若该缩略图需要压缩，放弃压缩逻辑以节约资源
            //        if (isPreview) return;
            //        //展示缩略图
            //        if (model.previewModel) {
            //            [self loadImageWithModel:model.previewModel isPreview:YES];
            //        }
            //
            //        //压缩
            //        [self scaleImageWithModel:model];
        }
        //    else if (model.animatedImage) {
        //
        //        //展示gif
        //        [self countLayoutWithImage:model.animatedImage completed:nil];
        //        self.imageView.animatedImage = model.animatedImage;
        //
        //    } else if (model.url) {
        //
        //        //判断是否存在缓存
        //        [YBImageBrowserDownloader memeryImageDataExistWithKey:model.url.absoluteString exist:^(BOOL exist) {
        //            YB_MAINTHREAD_ASYNC(^{
        //                if (exist) {
        //                    //缓存存在
        //                    [self queryCacheWithModel:model];
        //                } else {
        //                    //缓存不存在
        //                    //若该缩略图无缓存，放弃下载逻辑以节约资源
        //                    if (isPreview) return;
        //                    //展示缩略图
        //                    if (model.previewModel) {
        //                        [self loadImageWithModel:model.previewModel isPreview:YES];
        //                    }
        //                    //下载逻辑
        //                    [self downLoadImageWithModel:model];
        //                }
        //            })
        //        }];
        //    }
    }
    
    @objc private func singleGesture(_ tap: UITapGestureRecognizer) {
        delegate?.applyHidden(by: self)
    }
    
    @objc private func doubleGesture(_ tap: UITapGestureRecognizer) {
        let point = tap.location(in: imageView)
        guard imageView.bounds.contains(point) else { return }
        
        if scrollView.zoomScale == scrollView.maximumZoomScale {
            scrollView.setZoomScale(1, animated: true)
        } else {
            /// 让指定区域尽可能大的显示在可视区域
            let rect = CGRect(x: point.x, y: point.y, width: 1, height: 1)
            scrollView.zoom(to: rect, animated: true)
        }
    }
    
    @objc private func longPressGesture(_ press: UILongPressGestureRecognizer) {
        guard press.state == .began else { return }
        delegate?.photoBrowserCell(self, longPressBegin: press)
    }
}

// MARK: - Image calculate funcs

extension LPPhotoBrowserCell {
    
    @discardableResult
    private func calculateLayout(_ model: LPPhotoBrowserModel,
                                 image: UIImage) -> CGRect {
        let info = LPPhotoBrowserCellVM.calculateImage(containerSize: scrollView.bounds.size, image: image)
        
        scrollView.contentSize = info.contentSize
        scrollView.minimumZoomScale = info.minimumZoomScale
        
        let config = LPPhotoBrowserConfig.shared
        if config.autoCountMaximumZoomScale {
            scrollView.maximumZoomScale = info.maximumZoomScale * 1.2
        } else {
            scrollView.maximumZoomScale = model.maximumZoomScale
        }
        
        imageView.frame = info.imageFrame
        
        print("2.imageView.frame=\(imageView.frame)")
        
        return info.imageFrame
    }
}

// MARK: - cutImage


////裁剪
//- (void)cutImage {
//
//    UIScrollView *scrollView = self.scrollView;
//
//    CGFloat scale = ((UIImage *)[self.model valueForKey:YBImageBrowserModel_KVCKey_largeImage]).size.width / self.scrollView.contentSize.width;
//    CGFloat x = scrollView.contentOffset.x * scale,
//    y = scrollView.contentOffset.y * scale,
//    width = scrollView.bounds.size.width * scale,
//    height = scrollView.bounds.size.height * scale;
//
//    if (width > YBImageBrowser.maxDisplaySize || height > YBImageBrowser.maxDisplaySize) {
//        return;
//    }
//
//    YBImageBrowserModelCutImageSuccessBlock successBlock = ^(YBImageBrowserModel *backModel, UIImage *targetImage){
//        if (self && self.model == backModel) {
//            [self showLocalImageViewWithImage:targetImage];
//        }
//    };
//    ((void(*)(id, SEL, CGRect, YBImageBrowserModelCutImageSuccessBlock)) objc_msgSend)(self.model, sel_registerName(YBImageBrowserModel_SELName_cutImage), CGRectMake(x, y, width, height), successBlock);
//}

// MARK: - showLocalImageViewWithImage

//- (void)showLocalImageViewWithImage:(UIImage *)image {
//    if (self.localImageView.isHidden) {
//        self.localImageView.hidden = NO;
//    }
//    self.localImageView.frame = self.bounds;
//    self.localImageView.image = image;
//}
//
//- (void)hideLocalImageView {
//    if (!self.localImageView.isHidden) {
//        self.localImageView.hidden = YES;
//    }
//}

// MARK: - showProgressBar

//- (void)showProgressBar {
//    if (!self.progressBar.superview) {
//        [self.contentView addSubview:self.progressBar];
//    }
//}
//
//- (void)hideProgressBar {
//    if (self.progressBar.superview) {
//        [self.progressBar removeFromSuperview];
//    }
//}

// MARK: - queryCacheWithModel

////查找缓存
//- (void)queryCacheWithModel:(YBImageBrowserModel *)model {
//    [YBImageBrowserDownloader queryCacheOperationForKey:model.url.absoluteString completed:^(UIImage * _Nullable image, NSData * _Nullable data) {
//        YB_MAINTHREAD_ASYNC(^{
//            if ([YBImageBrowserUtilities isGif:data]) {
//                if (data) {
//                    model.animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
//                    if (self.model == model) {
//                        [self loadImageWithModel:model isPreview:NO];
//                    }
//                }
//            } else {
//                if (image) {
//                    model.image = image;
//                    if (self.model == model) {
//                        [self loadImageWithModel:model isPreview:NO];
//                    }
//                }
//            }
//        })
//    }];
//}

// MARK: - downLoadImageWithModel

////下载
//- (void)downLoadImageWithModel:(YBImageBrowserModel *)model {
//
//    [self showProgressBar];
//
//    YBImageBrowserModelDownloadProgressBlock progressBlock = ^(YBImageBrowserModel * _Nonnull backModel, NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
//        //下载中，进度显示
//        if (self.model != backModel || expectedSize <= 0) return;
//        CGFloat progress = receivedSize * 1.0 / expectedSize;
//        if (progress < 0) return;
//        YB_MAINTHREAD_ASYNC(^{
//            [self showProgressBar];
//            self.progressBar.progress = progress;
//        })
//    };
//
//    YBImageBrowserModelDownloadSuccessBlock successBlock = ^(YBImageBrowserModel * _Nonnull backModel, UIImage * _Nullable image, NSData * _Nullable data, BOOL finished) {
//        //下载成功，移除 ProgressBar 并且刷新图片
//        if (self.model == backModel) {
//            [self hideProgressBar];
//            [self loadImageWithModel:backModel isPreview:NO];
//        }
//    };
//
//    YBImageBrowserModelDownloadFailedBlock failedBlock = ^(YBImageBrowserModel * _Nonnull backModel, NSError * _Nullable error, BOOL finished) {
//        //下载失败，更新 ProgressBar 为错误提示
//        if (self.model == backModel) {
//            [self showProgressBar];
//            [self.progressBar showWithText:self.loadFailedText];
//        }
//    };
//
//    ((void(*)(id, SEL, YBImageBrowserModelDownloadProgressBlock, YBImageBrowserModelDownloadSuccessBlock, YBImageBrowserModelDownloadFailedBlock)) objc_msgSend)(model, sel_registerName(YBImageBrowserModel_SELName_download), progressBlock, successBlock, failedBlock);
//}

// MARK: - scaleImageWithModel 压缩

////压缩
//- (void)scaleImageWithModel:(YBImageBrowserModel *)model {
//
//    UIImage *largeImage = [model valueForKey:YBImageBrowserModel_KVCKey_largeImage];
//
//    [self countLayoutWithImage:largeImage completed:^(CGRect imageFrame) {
//
//        [self showProgressBar];
//        [self.progressBar showWithText:self.isScaleImageText];
//
//        YBImageBrowserModelScaleImageSuccessBlock successBlock = ^(YBImageBrowserModel *backModel) {
//            if (self && self.model == backModel) {
//                [self hideProgressBar];
//                self.imageView.image = backModel.image;
//            }
//        };
//        ((void(*)(id, SEL, CGRect, YBImageBrowserModelScaleImageSuccessBlock)) objc_msgSend)(model, sel_registerName(YBImageBrowserModel_SELName_scaleImage), imageFrame, successBlock);
//    }];
//}
