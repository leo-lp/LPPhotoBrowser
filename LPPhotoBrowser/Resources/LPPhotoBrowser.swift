//
//  LPPhotoBrowser.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/5/28.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

public class LPPhotoBrowser: UIViewController {
    
    // MARK: - Static Propertys
   
    static private(set) var isControllerPreferredForStatusBar: Bool = true
    static private(set) var isHiddenOfStatusBarBefore: Bool = false
    static public var isHideStatusBar: Bool = true
    
    // MARK: - Custom Propertys
    
    public weak var dataSource: LPPhotoBrowserDataSource?
    public weak var delegate: LPPhotoBrowserDelegate?
    
    public private(set) var currentIndex: Int = 0
    
    public private(set) var type: LPPhotoBrowserType = .default
    
    public var isLongPressGestureEnabled: Bool = true
    
    private var isViewDidAppear: Bool = false
    private var backgroundColor: UIColor = UIColor.black
    
    private(set) var browserView: LPPhotoBrowserView = {
        let layout = LPPhotoBrowserViewLayout()
        return LPPhotoBrowserView(frame: .zero,
                                  collectionViewLayout: layout)
    }()
    
    // MARK: - Override Funcs
    
    deinit {
        #if DEBUG
        print("LPPhotoBrowser: -> release memory.")
        #endif
    }
    
    public init(type: LPPhotoBrowserType, index: Int) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
        self.currentIndex = index
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = backgroundColor
        
        if LPPhotoBrowser.isControllerPreferredForStatusBar
            && LPPhotoBrowser.isHideStatusBar
            && !LPPhotoBrowser.isHiddenOfStatusBarBefore {
            configStatusBarHide(true)
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let isHidden = UIApplication.shared.isStatusBarHidden
        LPPhotoBrowser.isHiddenOfStatusBarBefore = isHidden
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !isViewDidAppear else { return }
        browserView.dataSource = self
        browserView.delegate = self
        view.addSubview(browserView)
        
        browserView.scrollToIndex(currentIndex)
        
//        [self setTooBarNumberCountWithCurrentIndex:_currentIndex+1];
        
        isViewDidAppear = true
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if LPPhotoBrowser.isControllerPreferredForStatusBar
            && LPPhotoBrowser.isHideStatusBar
            && !LPPhotoBrowser.isHiddenOfStatusBarBefore {
            configStatusBarHide(false)
        }
    }
    
    public override var prefersStatusBarHidden: Bool {
        return LPPhotoBrowser.isHideStatusBar
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        browserView.frame = view.bounds
        browserView.scrollToIndex(currentIndex)
    }
}

// MARK: - Open Funcs

extension LPPhotoBrowser {
    
    public func show(from controller: UIViewController? = nil,
                   completion: (() -> Void)?) {
        guard let vc = controller ?? UIViewController.topController()
            else { return }
        vc.present(self, animated: true, completion: completion)
    }
    
    public func hide(_ completion: (() -> Void)?) {
        if !LPPhotoBrowser.isControllerPreferredForStatusBar {
            let isHidden = LPPhotoBrowser.isHiddenOfStatusBarBefore
            UIApplication.shared.isStatusBarHidden = isHidden
        }
        dismiss(animated: true, completion: completion)
    }
}

// MARK: - Delegate funcs

extension LPPhotoBrowser: UICollectionViewDataSource, UICollectionViewDelegate, LPBrowserCellDelegate {
    
    // MARK: - UICollectionViewDataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dataSource = dataSource else { return 0 }
        return dataSource.photoBrowser(self, numberOf: type)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let source = dataSource?.photoBrowser(self,
                                              sourceAt: indexPath.item,
                                              of: type)
        return browserView.configCell(with: source,
                                      delegate: self,
                                      at: indexPath)
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? LPPhotoBrowserCell)?.recoverSubviews()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? LPPhotoBrowserCell)?.recoverSubviews()
    }
    
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indexRatio = scrollView.contentOffset.x / scrollView.bounds.width
        let index = Int(indexRatio + 0.5)
        let numberOfItems = collectionView(browserView,
                                           numberOfItemsInSection: 0)
        guard index < numberOfItems && currentIndex != index else { return }
        
        let oldIndex = currentIndex
        currentIndex = index
        delegate?.photoBrowser(self,
                               indexDidChange: oldIndex,
                               newIndex: currentIndex,
                               of: type)
        
        //[self setTooBarNumberCountWithCurrentIndex:index+1];
    }
    
    // MARK: - LPBrowserCellDelegate
    
    func imageViewClicked() {
        hide(nil)
    }
    
    func imageViewLongPressBegin() {
        guard isLongPressGestureEnabled else { return }
        
    }
    
    func dismissWhenEndDragging() {
        hide(nil)
    }
    
    func hideWhenStartDragging() {
        guard !browserView.isHidden else { return }
        browserView.isHidden = true
    }
    
    func showWhenEndDragging() {
        view.backgroundColor = backgroundColor.withAlphaComponent(1)
        guard browserView.isHidden else { return }
        browserView.isHidden = false
    }
    
    func show(with duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.view.backgroundColor = self.backgroundColor.withAlphaComponent(1)
        }
    }
    
    func changeAlphaWhenDragging(_ alpha: CGFloat) {
        view.backgroundColor = backgroundColor.withAlphaComponent(alpha)
    }
}

extension LPPhotoBrowser: UIViewControllerTransitioningDelegate, LPPhotoBrowserAnimatedDelegate {
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LPPhotoBrowserAnimatedTransitioning(delegate: self)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LPPhotoBrowserAnimatedTransitioning(delegate: self)
    }
}

//- (void)judgeAlbumAuthorizationStatusSuccess:(void(^)(void))success {
//    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
//    if (status == PHAuthorizationStatusDenied) {
//        [YB_NORMALWINDOW yb_showForkPromptWithText:self.copywriter.albumAuthorizationDenied];
//    } else if(status == PHAuthorizationStatusNotDetermined){
//        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
//            if (status == PHAuthorizationStatusAuthorized) {
//                if (success) success();
//            } else {
//                YBLOG_WARNING(@"user is not Authorized");
//            }
//        }];
//    } else if (status == PHAuthorizationStatusAuthorized){
//        if (success) success();
//    }
//}
//
//- (void)saveGifToAlbumWithData:(NSData *)data {
//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//    [library writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
//        if (!error) {
//            [YB_NORMALWINDOW yb_showHookPromptWithText:self.copywriter.saveImageDataToAlbumSuccessful];
//        } else {
//            [YB_NORMALWINDOW yb_showForkPromptWithText:self.copywriter.saveImageDataToAlbumFailed];
//        }
//    }];
//}
//
//- (void)savePhotoToAlbumWithImage:(UIImage *)image {
//    UIImageWriteToSavedPhotosAlbum(image, self.class, @selector(completedWithImage:error:context:), (__bridge void *)self);
//}
//
//+ (void)completedWithImage:(UIImage *)image error:(NSError *)error context:(void *)context {
//    id obj = (__bridge id)context;
//    if (!obj || ![obj isKindOfClass:[YBImageBrowser class]]) return;
//    YBImageBrowserCopywriter *copywriter = ((YBImageBrowser *)obj).copywriter;
//    if (!error) {
//        [YB_NORMALWINDOW yb_showHookPromptWithText:copywriter.saveImageDataToAlbumSuccessful];
//    } else {
//        [YB_NORMALWINDOW yb_showForkPromptWithText:copywriter.saveImageDataToAlbumFailed];
//    }
//}

// MARK: - Private Funcs

extension LPPhotoBrowser {
    
    private func commonInit() {
        transitioningDelegate = self
        modalPresentationStyle = .custom
//    fuctionDataArray = @[[YBImageBrowserFunctionModel functionModelForSavePictureToAlbum]];
        statusBarConfigByInfoPlist()
    }
    
    private func statusBarConfigByInfoPlist() {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist")
            , let data = FileManager.default.contents(atPath: path) else { return }
        var format = PropertyListSerialization.PropertyListFormat.xml
        do {
            let objc = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: &format)
            guard let dict = objc as? [String: AnyObject] else { return }
            let flag = dict["UIViewControllerBasedStatusBarAppearance"]?.boolValue
            LPPhotoBrowser.isControllerPreferredForStatusBar = flag ?? true
        } catch {
            print(error)
        }
    }
    
    private func configStatusBarHide( _ hide: Bool) {
        guard let statusBarWindow = UIApplication.shared.value(forKey: "statusBarWindow") as? NSObject
            , let statusBar = statusBarWindow.value(forKey: "statusBar") as? UIView else { return }
        statusBar.alpha = hide ? 0 : 1
    }

    //- (void)setTooBarNumberCountWithCurrentIndex:(NSInteger)index {
    //    NSInteger totalCount = 0;
    //    if (self.dataArray) {
    //        totalCount = self.dataArray.count;
    //    } else if (_dataSource && [_dataSource respondsToSelector:@selector(numberInYBImageBrowser:)]) {
    //        totalCount = [_dataSource numberInYBImageBrowser:self];
    //    }
    //    [self.toolBar setTitleLabelWithCurrentIndex:index totalCount:totalCount];
    //}
    //
    //- (void)setTooBarHideWithDataSourceCount:(NSInteger)count {
    //    if (count <= 1) {
    //        if(!self.toolBar.titleLabel.isHidden) self.toolBar.titleLabel.hidden = YES;
    //    } else {
    //        if (self.toolBar.titleLabel.isHidden) self.toolBar.titleLabel.hidden = NO;
    //    }
    //}
}





//- (void)setFuctionDataArray:(NSArray<YBImageBrowserFunctionModel *> *)fuctionDataArray {
//    _fuctionDataArray = fuctionDataArray;
//    if (fuctionDataArray.count == 0) {
//        [self.toolBar setRightButtonHide:YES];
//    } else if (fuctionDataArray.count == 1) {
//        YBImageBrowserFunctionModel *model = fuctionDataArray[0];
//        if (model.image) {
//            [self.toolBar setRightButtonImage:model.image];
//            [self.toolBar setRightButtonTitle:nil];
//        } else if (model.name) {
//            [self.toolBar setRightButtonImage:nil];
//            [self.toolBar setRightButtonTitle:model.name];
//        } else {
//            [self.toolBar setRightButtonImage:nil];
//            [self.toolBar setRightButtonTitle:nil];
//            YBLOG_WARNING(@"the only model in fuctionDataArray is invalid");
//        }
//    } else {
//        [self.toolBar setRightButtonImage:[UIImage imageWithContentsOfFile:[[NSBundle yBImageBrowserBundle] pathForResource:@"ybImageBrowser_more" ofType:@"png"]]];
//        [self.toolBar setRightButtonTitle:nil];
//        //functionBar 方法仅在此处调用其它地方均用实例变量方式访问
//        self.functionBar.dataArray = fuctionDataArray;
//    }
//}
//
//- (void)setDownloaderShouldDecompressImages:(BOOL)downloaderShouldDecompressImages {
//    _downloaderShouldDecompressImages = downloaderShouldDecompressImages;
//    [YBImageBrowserDownloader shouldDecompressImages:downloaderShouldDecompressImages];
//}

//- (YBImageBrowserCopywriter *)copywriter {
//    if (!_copywriter) {
//        _copywriter = [YBImageBrowserCopywriter new];
//    }
//    return _copywriter;
//}

//#pragma mark save photo to album
//
//- (void)savePhotoToAlbumWithCurrentIndex {
//    YBImageBrowserView *browserView = self.browserView;
//    if (!browserView) return;
//    YBImageBrowserCell *cell = (YBImageBrowserCell *)[browserView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:browserView.currentIndex inSection:0]];
//    if (!cell) return;
//    if (cell.model) [self savePhotoToAlbumWithModel:cell.model preview:NO];
//}
//
//- (void)savePhotoToAlbumWithModel:(YBImageBrowserModel *)model preview:(BOOL)preview {
//    if (model.needCutToShow) {
//        [self judgeAlbumAuthorizationStatusSuccess:^{
//            UIImage *largeImage = [model valueForKey:YBImageBrowserModel_KVCKey_largeImage];
//            if (largeImage) [self savePhotoToAlbumWithImage:largeImage];
//        }];
//    } if (model.image) {
//        [self judgeAlbumAuthorizationStatusSuccess:^{
//            [self savePhotoToAlbumWithImage:model.image];
//        }];
//    } else if (model.animatedImage) {
//        if (model.animatedImage.data) {
//            [self judgeAlbumAuthorizationStatusSuccess:^{
//                [self saveGifToAlbumWithData:model.animatedImage.data];
//            }];
//        } else {
//            YBLOG_WARNING(@"instance of FLAnimatedImage is exist, but it's key-data is not exist, this maybe the BUG of the framework of FLAnimatedImage");
//        }
//    } else {
//        if (!preview) {
//            [self savePhotoToAlbumWithModel:model.previewModel preview:YES];
//        } else {
//            [YB_NORMALWINDOW yb_showForkPromptWithText:self.copywriter.noImageDataToSave];
//        }
//    }
//}

//#pragma mark YBImageBrowserToolBarDelegate
//
//- (void)yBImageBrowserToolBar:(YBImageBrowserToolBar *)imageBrowserToolBar didClickRightButton:(UIButton *)button {
//    if (!self.fuctionDataArray.count) return;
//    if (self.fuctionDataArray.count == 1 && [self.fuctionDataArray[0].ID isEqualToString:YBImageBrowserFunctionModel_ID_savePictureToAlbum]) {
//        //直接保存图片
//        [self savePhotoToAlbumWithCurrentIndex];
//    } else {
//        //弹出功能栏
//        if (_functionBar) {
//            [_functionBar show];
//        }
//    }
//}
//
//#pragma mark YBImageBrowserFunctionBarDelegate
//
//- (void)ybImageBrowserFunctionBar:(YBImageBrowserFunctionBar *)functionBar clickCellWithModel:(YBImageBrowserFunctionModel *)model {
//
//    if ([model.ID isEqualToString:YBImageBrowserFunctionModel_ID_savePictureToAlbum]) {
//        [self savePhotoToAlbumWithCurrentIndex];
//    } else {
//        if (_delegate && [_delegate respondsToSelector:@selector(yBImageBrowser:clickFunctionBarWithModel:)]) {
//            [_delegate yBImageBrowser:self clickFunctionBarWithModel:model];
//        } else {
//            YBLOG_WARNING(@"you are not handle events of functionBar");
//        }
//    }
//}
