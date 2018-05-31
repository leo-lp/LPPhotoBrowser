//
//  LPPhotoBrowser.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/5/28.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

open class LPPhotoBrowser: UIViewController {
    
    // MARK: - Static Propertys
   
    /// 状态栏是否是控制器优先
    static var isControllerPreferredForStatusBar: Bool = true
    static var maxDisplaySize: CGFloat = 3500
    static var isHideStatusBar: Bool = true
    
    /// 状态栏在模态切换之前是否隐藏
    static var isHideStatusBarBefore: Bool = false
    
    // MARK: - Custom Propertys
    
    open weak var delegate: LPPhotoBrowserDelegate?
    
    open var dataModels: [LPPhotoBrowserModel]?
    open var currentIndex: Int = 0
    
    open var isCancelLongPressGesture: Bool = false /// 取消长按手势的响应
    
    private var isViewDidAppear: Bool = false
    private var backgroundColor: UIColor = UIColor.black
    
    private(set) lazy var browserView: LPPhotoBrowserView = {
        let layout = LPPhotoBrowserViewLayout()
        let browser = LPPhotoBrowserView(frame: .zero,
                                         collectionViewLayout: layout)
        browser.pb_delegate = self
        browser.pb_dataSource = self
        return browser
    }()
    
    // MARK: - Override Funcs
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        log.warning("release memory.")
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = backgroundColor
        
        if LPPhotoBrowser.isControllerPreferredForStatusBar
            && LPPhotoBrowser.isHideStatusBar
            && !LPPhotoBrowser.isHideStatusBarBefore {
            configStatusBarHide(true)
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let isHidden = UIApplication.shared.isStatusBarHidden
        LPPhotoBrowser.isHideStatusBarBefore = isHidden
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !isViewDidAppear else { return }
        
        setupBrowserView()
        setupToolBar()
        
        view.addSubview(browserView)
        
//        [self.view addSubview:self.toolBar];
        browserView.scrollToPageIndex(currentIndex)
        
//        [self setTooBarNumberCountWithCurrentIndex:_currentIndex+1];

        isViewDidAppear = true
        
        browserView.layer.borderColor = UIColor.red.cgColor
        browserView.layer.borderWidth = 1
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if LPPhotoBrowser.isControllerPreferredForStatusBar
            && LPPhotoBrowser.isHideStatusBar
            && !LPPhotoBrowser.isHideStatusBarBefore {
            configStatusBarHide(false)
        }
    }
    
    open override var prefersStatusBarHidden: Bool {
        return LPPhotoBrowser.isHideStatusBar
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        browserView.frame = view.bounds
//        browserView.reloadData()
//        browserView.layoutIfNeeded()
//        browserView.scrollToPageIndex(currentIndex)
    }
}

// MARK: - Open Funcs

extension LPPhotoBrowser {
    
    open func show(from controller: UIViewController? = nil,
                   completion: (() -> Void)?) {
        guard let vc = controller ?? UIViewController.topController()
            else { return }
        
        guard let models = dataModels, models.count > 0 else {
            return log.error("dataModels is invalid.")
        }
        
        //    if (self.dataArray) {
        //    } else if (_dataSource && [_dataSource respondsToSelector:@selector(numberInYBImageBrowser:)]) {
        //        if (![_dataSource numberInYBImageBrowser:self]) {
        //            YBLOG_ERROR(@"numberInYBImageBrowser: is invalid");
        //            return;
        //        }
        //    } else {
        //        YBLOG_ERROR(@"the data source is invalid");
        //        return;
        //    }
        vc.present(self, animated: true, completion: completion)
    }
    
    open func hide(_ completion: (() -> Void)?) {
        if !LPPhotoBrowser.isControllerPreferredForStatusBar {
            UIApplication.shared.isStatusBarHidden = LPPhotoBrowser.isHideStatusBarBefore
        }
        dismiss(animated: true, completion: completion)
    }
}

// MARK: - Delegate funcs

extension LPPhotoBrowser: UIViewControllerTransitioningDelegate, LPPhotoBrowserViewDelegate, LPPhotoBrowserViewDataSource, LPPhotoBrowserAnimatedDelegate {
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LPPhotoBrowserAnimatedTransitioning(delegate: self)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LPPhotoBrowserAnimatedTransitioning(delegate: self)
    }
    
    // MARK: - LPPhotoBrowserViewDelegate
    
    func photoBrowserView(_ browserView: LPPhotoBrowserView, didScrollTo index: Int) {
        currentIndex = index
        //    [self setTooBarNumberCountWithCurrentIndex:index+1];
        
        delegate?.photoBrowser(self, didScrollTo: index)
    }
    
    func photoBrowserView(_ browserView: LPPhotoBrowserView, longPressBegin press: UILongPressGestureRecognizer) {
        guard !isCancelLongPressGesture else { return }
        
        //    if (self.fuctionDataArray.count > 1) {
        //        //弹出功能栏
        //        if (_functionBar) { [_functionBar show]; }
        //    }
    }
    
    func applyHidden(in browserView: LPPhotoBrowserView) {
        hide(nil)
    }
    
    func photoBrowserView(_ browserView: LPPhotoBrowserView, changeAlphaWhenDragging alpha: CGFloat) {
        view.backgroundColor = backgroundColor.withAlphaComponent(alpha)
    }
    
    func photoBrowserView(_ browserView: LPPhotoBrowserView, willShowBrowerViewWith timeInterval: TimeInterval) {
        UIView.animate(withDuration: timeInterval) {
            self.view.backgroundColor = self.backgroundColor.withAlphaComponent(1)
        }
    }
    
    func showBrowerViewWhenEndDragging(in browserView: LPPhotoBrowserView) {
        view.backgroundColor = backgroundColor.withAlphaComponent(1)
        guard browserView.isHidden else { return }
        browserView.isHidden = false
    }
    
    // MARK: - LPPhotoBrowserViewDataSource
    
    func numberOfPhotos(in browserView: LPPhotoBrowserView) -> Int {
        if let models = dataModels {
            let count = models.count
            //        [self setTooBarHideWithDataSourceCount:count];
            return count
        }
        //    } else if (_dataSource && [_dataSource respondsToSelector:@selector(numberInYBImageBrowser:)]) {
        //        NSUInteger count = [_dataSource numberInYBImageBrowser:self];
        //        [self setTooBarHideWithDataSourceCount:count];
        //        return count;
        //    }
        return 0
    }
    
    func photoBrowserView(_ browserView: LPPhotoBrowserView, modelForCellAt index: Int) -> LPPhotoBrowserModel? {
        if let models = dataModels, models.count > index {
            return models[index]
        }
//        else if (_dataSource && [_dataSource respondsToSelector:@selector(yBImageBrowser:modelForCellAtIndex:)]) {
            //        return [_dataSource yBImageBrowser:self modelForCellAtIndex:index];
            //    }
        return nil
    }
}


//
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
        
//    isDealViewDidAppear = NO;
//    _cancelLongPressGesture = NO;
//    _yb_supportedInterfaceOrientations = UIInterfaceOrientationMaskAllButUpsideDown;
//    _cancelLongPressGesture = NO;
//    _inAnimation = YBImageBrowserAnimationMove;
//    _outAnimation = YBImageBrowserAnimationMove;
//    window = [YBImageBrowserUtilities getNormalWindow];
//    self.fuctionDataArray = @[[YBImageBrowserFunctionModel functionModelForSavePictureToAlbum]];
        
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

    private func setupBrowserView() {
//    self.browserView.loadFailedText = self.copywriter.loadFailedText;
//    self.browserView.isScaleImageText = self.copywriter.isScaleImageText;
    }
    
    private func setupToolBar() {
        
    }
    
    ////获取屏幕展示的方向
    //- (YBImageBrowserScreenOrientation)getScreenOrientationByStatusBar {
    //    UIInterfaceOrientation obr = [UIApplication sharedApplication].statusBarOrientation;
    //    if ((obr == UIInterfaceOrientationPortrait) || (obr == UIInterfaceOrientationPortraitUpsideDown)) {
    //        return YBImageBrowserScreenOrientationVertical;
    //    } else if ((obr == UIInterfaceOrientationLandscapeLeft) || (obr == UIInterfaceOrientationLandscapeRight)) {
    //        return YBImageBrowserScreenOrientationHorizontal;
    //    } else {
    //        return YBImageBrowserScreenOrientationUnknown;
    //    }
    //}
    
    ////根据 device 方向改变 UI
    //- (void)resetUserInterfaceLayoutByDeviceOrientation {
    //
    //    YBImageBrowserScreenOrientation so;
    //    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    //    BOOL isVertical = (deviceOrientation == UIDeviceOrientationPortrait && (supportAutorotateTypes & UIInterfaceOrientationMaskPortrait)) || (deviceOrientation == UIInterfaceOrientationPortraitUpsideDown && (supportAutorotateTypes & UIInterfaceOrientationMaskPortraitUpsideDown));
    //    BOOL isHorizontal = (deviceOrientation == UIDeviceOrientationLandscapeRight && (supportAutorotateTypes & UIInterfaceOrientationMaskLandscapeLeft)) || (deviceOrientation == UIDeviceOrientationLandscapeLeft && (supportAutorotateTypes & UIInterfaceOrientationMaskLandscapeRight));
    //    if (isVertical) {
    //        so = YBImageBrowserScreenOrientationVertical;
    //    } else if(isHorizontal) {
    //        so = YBImageBrowserScreenOrientationHorizontal;
    //    } else {
    //        return;
    //    }
    //
    //    //发送将要转屏更新 UI 的广播
    //    [[NSNotificationCenter defaultCenter] postNotificationName:YBImageBrowser_notification_willToRespondsDeviceOrientation object:nil];
    //
    //    //将正在执行的拖拽动画取消
    //    [self yBImageBrowser_notification_showBrowerView];
    //
    //    //隐藏弹出功能栏、隐藏提示框
    //    if (_functionBar && _functionBar.superview) {
    //        [_functionBar hideWithAnimate:NO];
    //    }
    //    [self.view yb_hidePromptImmediately];
    //
    //    //更新UI
    //    [self so_updateFrameWithScreenOrientation:so];
    //}
    //
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


//- (YBImageBrowserToolBar *)toolBar {
//    if (!_toolBar) {
//        _toolBar = [YBImageBrowserToolBar new];
//        _toolBar.delegate = self;
//    }
//    return _toolBar;
//}
//
//- (YBImageBrowserFunctionBar *)functionBar {
//    if (!_functionBar) {
//        _functionBar = [YBImageBrowserFunctionBar new];
//        _functionBar.delegate = self;
//    }
//    return _functionBar;
//}
//
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
