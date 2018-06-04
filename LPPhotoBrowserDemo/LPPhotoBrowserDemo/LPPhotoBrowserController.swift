//
//  LPPhotoBrowserController.swift
//  LPPhotoBrowserDemo
//
//  Created by pengli on 2018/5/28.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit
import LPPhotoBrowser

class LPPhotoBrowserController: UICollectionViewController {
    var currentTouchIndexPath: IndexPath?
    
    let vm = LPPhotoBrowserVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let right = UIBarButtonItem(title: "清除缓存",
                                    style: .plain,
                                    target: self,
                                    action: #selector(clearCacheButtonClicked))
        navigationItem.rightBarButtonItem = right
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let collectionView = collectionView
            , let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let wh = (view.frame.width - 18.0) / 4.0
        layout.itemSize = CGSize(width: wh, height: wh)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.sectionInset = UIEdgeInsets(top: 0,
                                           left: 6,
                                           bottom: 0,
                                           right: 6)
        collectionView.collectionViewLayout = layout
    }
    
    @objc func clearCacheButtonClicked(_ sender: UIBarButtonItem) {
        KingfisherManager.shared.cache.clearMemoryCache()
        KingfisherManager.shared.cache.clearDiskCache()
    }
}

extension LPPhotoBrowserController {
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return vm.numberOfSections()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vm.numberOfItems(in: section)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LPPhotoBrowserCell", for: indexPath) as! LPPhotoBrowserCell
        let source = vm.sourceForConfigCell(at: indexPath)
        cell.bindData(with: source, at: indexPath)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "LPPhotoBrowserCellHeader", for: indexPath) as! LPPhotoBrowserCellHeader
        header.bindData(at: indexPath)
        return header
    }
    
    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentTouchIndexPath = indexPath
        
        let browser = LPPhotoBrowser(type: .image, index: indexPath.row)
        browser.dataSource = self
        browser.delegate = self
        browser.show(from: self, completion: nil)
    }
}

extension LPPhotoBrowserController: LPPhotoBrowserDataSource, LPPhotoBrowserDelegate {
    
    func photoBrowser(_ browser: LPPhotoBrowser, numberOf type: LPPhotoBrowserType) -> Int {
        switch type {
        case .image: return vm.imageNames.count
        case .album: return 0
        case .network: return vm.URLStrings.count
        }
    }
    
    func photoBrowser(_ browser: LPPhotoBrowser,
                      sourceAt index: Int,
                      of type: LPPhotoBrowserType) -> LPPhotoBrowserSource {
        switch type {
        case .image: return .image(UIImage(named: vm.imageNames[index]))
        case .album: return .image(UIImage(named: vm.imageNames[index]))
        case .network: return .image(UIImage(named: vm.imageNames[index]))
        }
    }
}

////YBImageBrowserDataSource 代理实现赋值数据
//- (NSInteger)numberInYBImageBrowser:(YBImageBrowser *)imageBrowser {
//    return self.dataArray1.count;
//}
//- (YBImageBrowserModel *)yBImageBrowser:(YBImageBrowser *)imageBrowser modelForCellAtIndex:(NSInteger)index {
//    YBImageBrowserModel *model = [YBImageBrowserModel new];
//    model.url = [NSURL URLWithString:self.dataArray1[index]];
//    model.sourceImageView = [self getImageViewOfCellByIndexPath:[NSIndexPath indexPathForRow:index inSection:1]];
//    return model;
//}
//- (UIImageView *)imageViewOfTouchForImageBrowser:(YBImageBrowser *)imageBrowser {
//    return [self getImageViewOfCellByIndexPath:currentTouchIndexPath];
//}
