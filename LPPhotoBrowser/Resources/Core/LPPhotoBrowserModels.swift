//
//  LPPhotoBrowserModels.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/5/29.
//  Copyright © 2018年 pengli. All rights reserved.
//

//import UIKit
//
//enum LPPhotoBrowserViewFillType {
//    case fullWidth // 宽度抵满屏幕宽度，高度不定
//    case completely // 保证图片完整显示情况下最大限度填充
//}

//@class YBImageBrowserModel;
//
//typedef void(^YBImageBrowserModelDownloadProgressBlock)(YBImageBrowserModel *backModel, NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL);
//typedef void(^YBImageBrowserModelDownloadSuccessBlock)(YBImageBrowserModel *backModel, UIImage * _Nullable image, NSData * _Nullable data, BOOL finished);
//typedef void(^YBImageBrowserModelDownloadFailedBlock)(YBImageBrowserModel *backModel, NSError * _Nullable error, BOOL finished);
//typedef void(^YBImageBrowserModelScaleImageSuccessBlock)(YBImageBrowserModel *backModel);
//typedef void(^YBImageBrowserModelCutImageSuccessBlock)(YBImageBrowserModel *backModel, UIImage *targetImage);
//
//FOUNDATION_EXTERN NSString * const YBImageBrowserModel_KVCKey_isLoading;
//FOUNDATION_EXTERN NSString * const YBImageBrowserModel_KVCKey_isLoadFailed;
//FOUNDATION_EXTERN NSString * const YBImageBrowserModel_KVCKey_largeImage;
//FOUNDATION_EXTERN char * const YBImageBrowserModel_SELName_download;
//FOUNDATION_EXTERN char * const YBImageBrowserModel_SELName_scaleImage;
//FOUNDATION_EXPORT char * const YBImageBrowserModel_SELName_cutImage;

//open class LPPhotoBrowserModel {
//    open var image: UIImage?
//    open var URLString: String?
//    
//    ///**
//    // 本地 gif 名字
//    // */
//    //@property (nonatomic, copy, nullable) NSString *gifName;
//    //
//    ///**
//    // 本地或者网络 gif 最终转换类型
//    // */
//    // FLAnimatedImage *animatedImage;
//    
//    open var sourceImageView: UIImageView?
//    
//    var maximumZoomScale: CGFloat = 4
//    
//    /// 是否需要裁剪显示
//    var needCutToShow: Bool = false
//    
//    /// 预览缩略图
//    //@property (nonatomic, strong, nullable) YBImageBrowserModel *previewModel;
//    
//    public init() { }
//}

//NSString * const YBImageBrowserModel_KVCKey_isLoading = @"isLoading";
//NSString * const YBImageBrowserModel_KVCKey_isLoadFailed = @"isLoadFailed";
//NSString * const YBImageBrowserModel_KVCKey_largeImage = @"largeImage";
//char * const YBImageBrowserModel_SELName_download = "downloadImageProgress:success:failed:";
//char * const YBImageBrowserModel_SELName_scaleImage = "scaleImageWithCurrentImageFrame:complete:";
//char * const YBImageBrowserModel_SELName_cutImage = "cutImageWithTargetRect:complete:";
//
//@interface YBImageBrowserModel () {
//    BOOL isLoading;
//    BOOL isLoadFailed;
//    BOOL isLoadSuccess;
//    __weak id downloadToken;
//    UIImage *largeImage;    //存储需要压缩的高清图
//    YBImageBrowserModelDownloadProgressBlock progressBlock;
//    YBImageBrowserModelDownloadSuccessBlock successBlock;
//    YBImageBrowserModelDownloadFailedBlock failedBlock;
//}
//
//@end
//
//@implementation YBImageBrowserModel
//
//#pragma mark life cycle
//
//- (void)dealloc {
//    if (downloadToken) {
//        [YBImageBrowserDownloader cancelTaskWithDownloadToken:downloadToken];
//    }
//}
//
//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        isLoading = NO;
//        isLoadFailed = NO;
//        isLoadSuccess = NO;
//        _needCutToShow = NO;
//    }
//    return self;
//}
//
//#pragma mark download
//
////下载图片
//- (void)downloadImageProgress:(YBImageBrowserModelDownloadProgressBlock)progress success:(YBImageBrowserModelDownloadSuccessBlock)success failed:(YBImageBrowserModelDownloadFailedBlock)failed {
//
//    YBImageBrowserModel *model = self;
//
//    if (!model.url || isLoadSuccess) return;    //不用处理回调的情况
//
//    progressBlock = progress;
//    successBlock = success;
//    failedBlock = failed;
//
//    if (isLoading) return;      //仍然处理回调转接（预下载与正式下载可能会同时请求）
//
//    isLoading = YES;
//
//    downloadToken = [YBImageBrowserDownloader downloadWebImageWithUrl:model.url progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
//
//        if (self->progressBlock) self->progressBlock(model, receivedSize, expectedSize, targetURL);
//
//    } success:^(UIImage * _Nullable image, NSData * _Nullable data, BOOL finished) {
//
//        isLoading = NO;
//        isLoadFailed = NO;
//        isLoadSuccess = YES;
//
//        //缓存处理
//        if ([YBImageBrowserUtilities isGif:data]) {
//            model.animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
//        } else {
//            model.image = image;
//        }
//        //该判断是为了防止图片加载框架的BUG影响内部逻辑
//        if (!model.animatedImage && !model.image) {
//            isLoading = NO;
//            isLoadFailed = YES;
//            if (self->failedBlock) self->failedBlock(model, nil, finished);
//        }
//        [YBImageBrowserDownloader storeImageDataWithKey:model.url.absoluteString image:image data:data];
//
//        if (self->successBlock) self->successBlock(model, image, data, finished);
//
//    } failed:^(NSError * _Nullable error, BOOL finished) {
//
//        isLoading = NO;
//        isLoadFailed = YES;
//        if (self->failedBlock) self->failedBlock(model, error, finished);
//
//    }];
//}
//
//#pragma mark scale and cut
//
////压缩图片
//- (void)scaleImageWithCurrentImageFrame:(CGRect)imageFrame complete:(YBImageBrowserModelScaleImageSuccessBlock)complete {
//    YBImageBrowserModel *model = self;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        model.image = [YBImageBrowserUtilities scaleToSizeWithImage:largeImage size:imageFrame.size];
//        if (complete) {
//            YB_MAINTHREAD_ASYNC(^{
//                complete(model);
//            })
//        }
//    });
//}
//
////裁剪图片
//- (void)cutImageWithTargetRect:(CGRect)targetRect complete:(YBImageBrowserModelCutImageSuccessBlock)complete {
//    YBImageBrowserModel *model = self;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        UIImage *resultImage = [YBImageBrowserUtilities cutToRectWithImage:largeImage rect:targetRect];
//        if (complete) {
//            YB_MAINTHREAD_ASYNC(^{
//                complete(model, resultImage);
//            })
//        }
//    });
//}
//
//#pragma mark public
//
//- (void)setImageWithFileName:(NSString *)fileName fileType:(NSString *)type {
//    self.image = YB_READIMAGE_FROMFILE(fileName, type);
//}
//
//- (void)setUrlWithDownloadInAdvance:(NSURL *)url {
//    _url = url;
//    [self downloadImageProgress:nil success:nil failed:nil];
//}
//
//#pragma mark setter
//
//- (void)setImage:(UIImage *)image {
//    if (image.size.width > YBImageBrowser.maxDisplaySize || image.size.height > YBImageBrowser.maxDisplaySize) {
//        self.needCutToShow = YES;
//        largeImage = image;
//    } else {
//        _image = image;
//    }
//}
//
//- (void)setGifName:(NSString *)gifName {
//    if (!gifName) return;
//    _gifName = gifName;
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:gifName ofType:@"gif"];
//    if (!filePath) return;
//    NSData *data = [NSData dataWithContentsOfFile:filePath];
//    if (!data) return;
//    _animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
//}
//
//@end
