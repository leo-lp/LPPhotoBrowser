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
    let vm = LPPhotoBrowserVM()
    
    deinit {
        print("LPPhotoBrowserController: -> release memory.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let right = UIBarButtonItem(barButtonSystemItem: .trash,
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
        let type: LPPhotoBrowserType = indexPath.section == 0 ? .default : .network
        
        let browser = LPPhotoBrowser(type: type, index: indexPath.row)
        browser.dataSource = self
        browser.delegate = self
        browser.show(from: self, completion: nil)
    }
}

extension LPPhotoBrowserController: LPPhotoBrowserDataSource, LPPhotoBrowserDelegate {
    
    func photoBrowser(_ browser: LPPhotoBrowser, numberOf type: LPPhotoBrowserType) -> Int {
        switch type {
        case .default: return vm.imageNames.count
        case .network: return vm.URLStrings.count
        default: return 0
        }
    }
    
    func photoBrowser(_ browser: LPPhotoBrowser,
                      sourceAt index: Int,
                      of type: LPPhotoBrowserType) -> LPPhotoBrowserSourceConvertible? {
        switch type {
        case .default:
            let imageName = vm.imageNames[index]
            let photo = LPNetworkPhoto()
            photo.placeholder = photoBrowser(browser, imageViewOfClickedAt: index, of: type)?.image
            
            if let url = Bundle.main.url(forResource: imageName, withExtension: nil) {
                photo.originalURL = url
            }
            return photo
        case .network:
            let photo = LPNetworkPhoto()
            photo.placeholder = photoBrowser(browser, imageViewOfClickedAt: index, of: type)?.image
            photo.originalURL = URL(string: vm.URLStrings[index])
            return photo
        default:
            return nil
        }
    }
    
    func photoBrowser(_ browser: LPPhotoBrowser,
                      imageViewOfClickedAt index: Int,
                      of type: LPPhotoBrowserType) -> UIImageView? {
        guard let collectionView = collectionView else { return nil }
        
        let section = type == .default ? 0 : 1
        let indexPath = IndexPath(item: index, section: section)
        return vm.imageView(in: collectionView, at: indexPath)
    }
}
