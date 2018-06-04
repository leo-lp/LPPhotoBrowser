
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        scrollView.setZoomScale(1, animated: true)
//
//        scrollView.frame = bounds
//        scrollView.contentSize = bounds.size
//        //self.progressBar.frame = self.bounds
//
//        print("scrollView.frame=\(scrollView.frame)")
//    }
//}

////- (void)reDownloadImageUrl {
////    if ([[self.model valueForKey:YBImageBrowserModel_KVCKey_isLoadFailed] boolValue] && ![[self.model valueForKey:YBImageBrowserModel_KVCKey_isLoading] boolValue]) {
////        [self downLoadImageWithModel:self.model];
////    }
////}
//}
//// MARK: - Private funcs
//
//    private func loadImage(with model: LPPhotoBrowserModel, isPreview: Bool) {
//        if let image = model.image {
//            // 若是压缩过后的图片，用原图计算缩放比例
//            if model.needCutToShow {
//                //[self countLayoutWithImage:[model valueForKey:YBImageBrowserModel_KVCKey_largeImage] completed:nil];
//            } else {
//                calculateLayout(model, image: image)
//            }
//            imageView.image = image
//        } else if model.needCutToShow {
//            //        //若该缩略图需要压缩，放弃压缩逻辑以节约资源
//            //        if (isPreview) return;
//            //        //展示缩略图
//            //        if (model.previewModel) {
//            //            [self loadImageWithModel:model.previewModel isPreview:YES];
//            //        }
//            //
//            //        //压缩
//            //        [self scaleImageWithModel:model];
//        }
//        //    else if (model.animatedImage) {
//        //
//        //        //展示gif
//        //        [self countLayoutWithImage:model.animatedImage completed:nil];
//        //        self.imageView.animatedImage = model.animatedImage;
//        //
//        //    } else if (model.url) {
//        //
//        //        //判断是否存在缓存
//        //        [YBImageBrowserDownloader memeryImageDataExistWithKey:model.url.absoluteString exist:^(BOOL exist) {
//        //            YB_MAINTHREAD_ASYNC(^{
//        //                if (exist) {
//        //                    //缓存存在
//        //                    [self queryCacheWithModel:model];
//        //                } else {
//        //                    //缓存不存在
//        //                    //若该缩略图无缓存，放弃下载逻辑以节约资源
//        //                    if (isPreview) return;
//        //                    //展示缩略图
//        //                    if (model.previewModel) {
//        //                        [self loadImageWithModel:model.previewModel isPreview:YES];
//        //                    }
//        //                    //下载逻辑
//        //                    [self downLoadImageWithModel:model];
//        //                }
//        //            })
//        //        }];
//        //    }
//    }

//
//    @objc private func longPressGesture(_ press: UILongPressGestureRecognizer) {
//        guard press.state == .began else { return }
//        delegate?.photoBrowserCell(self, longPressBegin: press)
//    }
//}
//
//// MARK: - cutImage
//
//
//////裁剪
////- (void)cutImage {
////
////    UIScrollView *scrollView = self.scrollView;
////
////    CGFloat scale = ((UIImage *)[self.model valueForKey:YBImageBrowserModel_KVCKey_largeImage]).size.width / self.scrollView.contentSize.width;
////    CGFloat x = scrollView.contentOffset.x * scale,
////    y = scrollView.contentOffset.y * scale,
////    width = scrollView.bounds.size.width * scale,
////    height = scrollView.bounds.size.height * scale;
////
////    if (width > YBImageBrowser.maxDisplaySize || height > YBImageBrowser.maxDisplaySize) {
////        return;
////    }
////
////    YBImageBrowserModelCutImageSuccessBlock successBlock = ^(YBImageBrowserModel *backModel, UIImage *targetImage){
////        if (self && self.model == backModel) {
////            [self showLocalImageViewWithImage:targetImage];
////        }
////    };
////    ((void(*)(id, SEL, CGRect, YBImageBrowserModelCutImageSuccessBlock)) objc_msgSend)(self.model, sel_registerName(YBImageBrowserModel_SELName_cutImage), CGRectMake(x, y, width, height), successBlock);
////}
//
//// MARK: - showLocalImageViewWithImage
//
////- (void)showLocalImageViewWithImage:(UIImage *)image {
////    if (self.localImageView.isHidden) {
////        self.localImageView.hidden = NO;
////    }
////    self.localImageView.frame = self.bounds;
////    self.localImageView.image = image;
////}
////
////- (void)hideLocalImageView {
////    if (!self.localImageView.isHidden) {
////        self.localImageView.hidden = YES;
////    }
////}
//
//// MARK: - showProgressBar
//
////- (void)showProgressBar {
////    if (!self.progressBar.superview) {
////        [self.contentView addSubview:self.progressBar];
////    }
////}
////
////- (void)hideProgressBar {
////    if (self.progressBar.superview) {
////        [self.progressBar removeFromSuperview];
////    }
////}
//
//// MARK: - queryCacheWithModel
//
//////查找缓存
////- (void)queryCacheWithModel:(YBImageBrowserModel *)model {
////    [YBImageBrowserDownloader queryCacheOperationForKey:model.url.absoluteString completed:^(UIImage * _Nullable image, NSData * _Nullable data) {
////        YB_MAINTHREAD_ASYNC(^{
////            if ([YBImageBrowserUtilities isGif:data]) {
////                if (data) {
////                    model.animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
////                    if (self.model == model) {
////                        [self loadImageWithModel:model isPreview:NO];
////                    }
////                }
////            } else {
////                if (image) {
////                    model.image = image;
////                    if (self.model == model) {
////                        [self loadImageWithModel:model isPreview:NO];
////                    }
////                }
////            }
////        })
////    }];
////}
//
//// MARK: - downLoadImageWithModel
//
//////下载
////- (void)downLoadImageWithModel:(YBImageBrowserModel *)model {
////
////    [self showProgressBar];
////
////    YBImageBrowserModelDownloadProgressBlock progressBlock = ^(YBImageBrowserModel * _Nonnull backModel, NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
////        //下载中，进度显示
////        if (self.model != backModel || expectedSize <= 0) return;
////        CGFloat progress = receivedSize * 1.0 / expectedSize;
////        if (progress < 0) return;
////        YB_MAINTHREAD_ASYNC(^{
////            [self showProgressBar];
////            self.progressBar.progress = progress;
////        })
////    };
////
////    YBImageBrowserModelDownloadSuccessBlock successBlock = ^(YBImageBrowserModel * _Nonnull backModel, UIImage * _Nullable image, NSData * _Nullable data, BOOL finished) {
////        //下载成功，移除 ProgressBar 并且刷新图片
////        if (self.model == backModel) {
////            [self hideProgressBar];
////            [self loadImageWithModel:backModel isPreview:NO];
////        }
////    };
////
////    YBImageBrowserModelDownloadFailedBlock failedBlock = ^(YBImageBrowserModel * _Nonnull backModel, NSError * _Nullable error, BOOL finished) {
////        //下载失败，更新 ProgressBar 为错误提示
////        if (self.model == backModel) {
////            [self showProgressBar];
////            [self.progressBar showWithText:self.loadFailedText];
////        }
////    };
////
////    ((void(*)(id, SEL, YBImageBrowserModelDownloadProgressBlock, YBImageBrowserModelDownloadSuccessBlock, YBImageBrowserModelDownloadFailedBlock)) objc_msgSend)(model, sel_registerName(YBImageBrowserModel_SELName_download), progressBlock, successBlock, failedBlock);
////}
//
//// MARK: - scaleImageWithModel 压缩
//
//////压缩
////- (void)scaleImageWithModel:(YBImageBrowserModel *)model {
////
////    UIImage *largeImage = [model valueForKey:YBImageBrowserModel_KVCKey_largeImage];
////
////    [self countLayoutWithImage:largeImage completed:^(CGRect imageFrame) {
////
////        [self showProgressBar];
////        [self.progressBar showWithText:self.isScaleImageText];
////
////        YBImageBrowserModelScaleImageSuccessBlock successBlock = ^(YBImageBrowserModel *backModel) {
////            if (self && self.model == backModel) {
////                [self hideProgressBar];
////                self.imageView.image = backModel.image;
////            }
////        };
////        ((void(*)(id, SEL, CGRect, YBImageBrowserModelScaleImageSuccessBlock)) objc_msgSend)(model, sel_registerName(YBImageBrowserModel_SELName_scaleImage), imageFrame, successBlock);
////    }];
////}
