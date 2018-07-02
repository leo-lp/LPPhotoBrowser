//
//  LPPhotoManager.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/6/25.
//  Copyright © 2018年 pengli. All rights reserved.
//

import Photos

open class LPPhotoManager {
    //public static let shared: LPPhotoManager = { return LPPhotoManager() }()
    public init() { }
}

// MARK: - 保存图片

public extension LPPhotoManager {
    
    func savePhoto(_ image: UIImage, location: CLLocation?, completion: ((Error?) -> Void)?) {
        guard let data = UIImagePNGRepresentation(image)
            ?? UIImageJPEGRepresentation(image, 0.9) else {
            completion?(nil)
            return
        }
        savePhoto(data, location: location, completion: completion)
    }
    
    func savePhoto(_ data: Data, location: CLLocation?, completion: ((Error?) -> Void)?) {
        PHPhotoLibrary.shared().performChanges({
            let options = PHAssetResourceCreationOptions()
            options.shouldMoveFile = true
            
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, data: data, options: options)
            
            if let location = location {
                request.location = location
            }
            
            request.creationDate = Date()
            
        }) { (success, error) in
            DispatchQueue.main.async {
                if success {
                    completion?(nil)
                } else if let error = error {
                    print("保存照片出错：\(error.localizedDescription)")
                    completion?(error)
                }
            }
        }
    }
}

// MARK: - 相册权限认证

public extension LPPhotoManager {
    
    /// 如果得到了授权,返回true
    func authorizationStatusAuthorized() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    func requestAuthorization(_ completion: @escaping (_ authorized: Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        if status == .notDetermined {
            DispatchQueue.global().async {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    DispatchQueue.main.async {
                        completion(status == .authorized)
                    }
                })
            }
        }
        
        return completion(status == .authorized)
    }
}
