//
//  LPPhotoBrowserM.swift
//  LPPhotoBrowserDemo
//
//  Created by pengli on 2018/6/20.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit
import LPPhotoBrowser

class LPNetworkPhoto: LPPhotoBrowserSourceConvertible {
    var placeholder: UIImage? // 图片占位符
    var thumbnailURL: URL? // 缩略图URL
    var originalURL: URL? // 原图URL
    
    private var currImage: UIImage? // 当前Image
    
    public var asImage: UIImage? {
        return currImage ?? placeholder
    }
    
    public func asImage(_ progress: LPProgress?, completion: @escaping LPCompletion) {
        /// 设置占位符
        if let placeholder = placeholder {
            completion(placeholder)
        }
        
        /// 设置缩略图
        if let url = thumbnailURL {
            retrieveThumbnailImage(url: url, progress: progress, completion: completion)
        }

        /// 设置原图
        else if let url = originalURL {
            retrieveOriginalImage(url: url, progress: progress, completion: completion)
        }
    }
    
    private func retrieveThumbnailImage(url: URL, progress: LPProgress?, completion: @escaping LPCompletion) {
        let options: KingfisherOptionsInfo = [.preloadAllAnimationData]
        KingfisherManager.shared.retrieveImage(with: url, options: options, progressBlock: { (receivedSize, totalSize) in
            progress?(Float(receivedSize) / Float(totalSize))
        }) { [weak self](image, error, _, _) in
            guard let `self` = self else { return }
            
            if let thumbnailImage = image {
                completion(thumbnailImage)
            }
            
            if let url = self.originalURL {
                self.retrieveOriginalImage(url: url, progress: progress, completion: completion)
            }
        }
    }
    
    private func retrieveOriginalImage(url: URL, progress: LPProgress?, completion: @escaping LPCompletion) {
        let options: KingfisherOptionsInfo = [.preloadAllAnimationData]
        KingfisherManager.shared.retrieveImage(with: url, options: options, progressBlock: { (receivedSize, totalSize) in
            progress?(Float(receivedSize) / Float(totalSize))
        }) { (image, error, _, _) in
            
            if let originalImage = image {
                completion(originalImage)
            }
        }
    }
}
