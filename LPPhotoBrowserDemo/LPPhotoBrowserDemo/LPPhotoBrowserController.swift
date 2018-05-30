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
    
    @objc func clearCacheButtonClicked(_ sender: UIBarButtonItem) {
        KingfisherManager.shared.cache.clearMemoryCache()
        KingfisherManager.shared.cache.clearDiskCache()
    }
}

extension LPPhotoBrowserController: UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let wh = (view.frame.width - 18.0) / 4.0
        return CGSize(width: wh, height: wh)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 6.0, bottom: 0.0, right: 6.0)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return vm.numberOfSections()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vm.numberOfItems(in: section)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LPPhotoBrowserCell", for: indexPath) as! LPPhotoBrowserCell
        let name = vm.modelForConfigCell(at: indexPath)
        cell.bindData(with: name, at: indexPath)
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
        if indexPath.section == 0 {
            browserLocalImages(at: indexPath)
        } else {
            browserNetworkImages(at: indexPath)
        }
    }
}

//<, , YBImageBrowserDataSource>
extension LPPhotoBrowserController {
    
    private func browserLocalImages(at indexPath: IndexPath) {
        guard let collectionView = collectionView else { return }
        
        let browser = LPPhotoBrowser()
        browser.dataModels = vm.dataModels(in: collectionView)
        browser.currentIndex = indexPath.row
        
        browser.show(from: self, completion: nil)
    }
    
    private func browserNetworkImages(at indexPath: IndexPath) {
        let browser = LPPhotoBrowser()
        
        //    browser.dataSource = self;
        //    browser.currentIndex = indexPath.row;
        
        browser.show(from: self, completion: nil)
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
