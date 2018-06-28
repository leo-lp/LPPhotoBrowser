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
    
    public private(set) var type: LPPhotoBrowserType = .local
    
    private var isViewDidAppear: Bool = false
    private var backgroundColor: UIColor = UIColor.black
    
    private(set) var browserView: LPPhotoBrowserView = {
        let layout = LPPhotoBrowserViewLayout()
        return LPPhotoBrowserView(frame: .zero,
                                  collectionViewLayout: layout)
    }()
    
    private(set) weak var navigationBar: (UIView & LPNavigationBarDataSource)?
    
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
        
        if let navigation = dataSource?.navigationBar(in: self) {
            view.addSubview(navigation)
            navigation.totalCount = dataSource?.photoBrowser(self, numberOf: type) ?? 0
            navigation.currentIndex = currentIndex
            navigationBar = navigation
        }
        
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
        navigationBar?.currentIndex = currentIndex
        
        delegate?.photoBrowser(self,
                               indexDidChange: oldIndex,
                               newIndex: currentIndex,
                               of: type)
    }
    
    // MARK: - LPBrowserCellDelegate
    
    func imageViewClicked() {
        hide(nil)
    }
    
    func imageViewLongPressBegin() {
        if let delegate = delegate, !delegate.shouldLongPressGestureHandle() {
            return
        }
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "保存到相册", style: .default, handler: { (_) in
            guard let source = self.dataSource?.photoBrowser(self,
                                                             sourceAt: self.currentIndex,
                                                             of: self.type) else { return }
            source.asData(nil, completion: { (data) in
                guard let data = data else { return }
                LPPhotoManager.shared.savePhoto(data, location: nil, completion: { (error) in
                    
                })
            })
        }))
        actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
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

// MARK: - Private Funcs

extension LPPhotoBrowser {
    
    private func commonInit() {
        transitioningDelegate = self
        modalPresentationStyle = .custom
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
}
