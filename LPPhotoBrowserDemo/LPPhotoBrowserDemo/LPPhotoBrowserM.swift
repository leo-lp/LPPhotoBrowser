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
    
    var asCurrentImage: UIImage? { return currImage ?? placeholder }
    var asPlaceholder: UIImage? { return placeholder }
    
    func asThumbnail(_ progress: LPProgress?, completion: @escaping LPCompletion) {
        guard let url = thumbnailURL else { return completion(nil) }
        
        let options: KingfisherOptionsInfo = [.preloadAllAnimationData]
        KingfisherManager.shared.retrieveImage(with: url, options: options, progressBlock: { (receivedSize, totalSize) in
            progress?(Float(receivedSize) / Float(totalSize))
        }) { [weak self](image, error, cacheType, url) in
            
            if let thumbnail = image {
                print("thumbnail cacheType=\(cacheType, thumbnail.size)")
                
                self?.currImage = thumbnail
            }
            completion(image)
        }
    }
    
    func asOriginal(_ progress: LPProgress?, completion: @escaping LPCompletion) {
        guard let url = originalURL else { return completion(nil) }
        
        let options: KingfisherOptionsInfo = [.preloadAllAnimationData]
        KingfisherManager.shared.retrieveImage(with: url, options: options, progressBlock: { (receivedSize, totalSize) in
            progress?(Float(receivedSize) / Float(totalSize))
        }) { [weak self](image, error, cacheType, url) in
            
            if let originalImage = image {
                print("original cacheType=\(cacheType, originalImage.size)")
                
                self?.currImage = originalImage
                
                completion(originalImage)
            }
        }
    }
    
    func asData(_ progress: LPProgress?, completion: @escaping LPCompletion2) {
        let completionBlock: (UIImage) -> Void = { (image) in
            if let data = image.kf.animatedImageData {
                completion(data)
            } else {
                completion(UIImagePNGRepresentation(image) ?? UIImageJPEGRepresentation(image, 1.0))
            }
        }
        asOriginal(nil, completion: { (original) in
            if let original = original {
                completionBlock(original)
            } else {
                self.asThumbnail(nil, completion: { (thumbnail) in
                    if let thumbnail = thumbnail {
                        completionBlock(thumbnail)
                    } else {
                        if let placeholder = self.asPlaceholder {
                            completionBlock(placeholder)
                        }
                    }
                })
            }
        })
    }
}
