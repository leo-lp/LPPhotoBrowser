//
//  LPPhotoBrowserModels.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/5/29.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

public struct LPPhotoBrowserType: OptionSet, Hashable {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let `default` = LPPhotoBrowserType(rawValue: 1 << 1)
    public static let network   = LPPhotoBrowserType(rawValue: 1 << 2)
    public static let album     = LPPhotoBrowserType(rawValue: 1 << 3)
}

public typealias LPProgress = (_ percent: Float) -> Void
public typealias LPCompletion = (_ image: UIImage?) -> Void

public protocol LPPhotoBrowserSourceConvertible {
    var asImage: UIImage? { get }
    
    func asImage(_ progress: LPProgress?, completion: @escaping LPCompletion)
}

extension UIImage: LPPhotoBrowserSourceConvertible {
    public var asImage: UIImage? { return self }
    
    public func asImage(_ progress: LPProgress?, completion: @escaping LPCompletion) {
        return completion(self)
    }
}











//enum LPPhotoBrowserViewFillType {
//    case fullWidth // 宽度抵满屏幕宽度，高度不定
//    case completely // 保证图片完整显示情况下最大限度填充
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
