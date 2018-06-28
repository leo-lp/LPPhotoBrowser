//
//  LPPhotoBrowserVM.swift
//  LPPhotoBrowserDemo
//
//  Created by pengli on 2018/5/28.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit
import LPPhotoBrowser
import Photos

class LPPhotoBrowserVM {
    /// 1.本地图片
    var local: (String, [String]) = {
        var names: [String] = []
        for idx in 1...10 {
            let name = String(format: "girl-%02d.jpg", idx)
            names.append(name)
        }
        for idx in 1...9 {
            let name = String(format: "4k-%02d.jpg", idx)
            names.append(name)
        }
        for idx in 1...11 {
            let name = String(format: "GIF-%02d.gif", idx)
            names.append(name)
        }
        return ("本地图片", names)
    }()
    
    /// 2.网络图片
    var network: (String, [String]) = {
        return ("网络图片", [
            "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1524118984884&di=7c73ddf9d321ef94a19567337628580b&imgtype=0&src=http%3A%2F%2Fimg5q.duitang.com%2Fuploads%2Fitem%2F201506%2F07%2F20150607185100_XQvYT.jpeg",
            "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1524118934390&di=fbb86678336593d38c78878bc33d90c3&imgtype=0&src=http%3A%2F%2Fi2.hdslb.com%2Fbfs%2Farchive%2Fe90aa49ddb2fa345fa588cf098baf7b3d0e27553.jpg",
            "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1524118914981&di=7fa3504d8767ab709c4fb519ad67cf09&imgtype=0&src=http%3A%2F%2Fimg5.duitang.com%2Fuploads%2Fitem%2F201410%2F05%2F20141005221124_awAhx.jpeg",
            "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1524118687954&di=d92e4024fe4c2e4379cce3d3771ae105&imgtype=0&src=http%3A%2F%2Fimg3.duitang.com%2Fuploads%2Fitem%2F201605%2F18%2F20160518181939_nCZWu.gif",
            "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1524118772581&di=29b994a8fcaaf72498454e6d207bc29a&imgtype=0&src=http%3A%2F%2Fimglf2.ph.126.net%2F_s_WfySuHWpGNA10-LrKEQ%3D%3D%2F1616792266326335483.gif",
            "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1524118803027&di=beab81af52d767ebf74b03610508eb36&imgtype=0&src=http%3A%2F%2Fe.hiphotos.baidu.com%2Fbaike%2Fpic%2Fitem%2F2e2eb9389b504fc2995aaaa1efdde71190ef6d08.jpg",
            "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1524118823131&di=aa588a997ac0599df4e87ae39ebc7406&imgtype=0&src=http%3A%2F%2Fimg3.duitang.com%2Fuploads%2Fitem%2F201605%2F08%2F20160508154653_AQavc.png",
            "https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=722693321,3238602439&fm=27&gp=0.jpg",
            "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1524118892596&di=5e8f287b5c62ca0c813a548246faf148&imgtype=0&src=http%3A%2F%2Fwx1.sinaimg.cn%2Fcrop.0.0.1080.606.1000%2F8d7ad99bly1fcte4d1a8kj20u00u0gnb.jpg",
            "https://ww4.sinaimg.cn/bmiddle/5eef6257gw1ewy2m1cu5bg209g05bu0y.gif",
            "https://ww1.sinaimg.cn/bmiddle/9bd522c1gw1ewxg6soihgg209w05kx6q.gif",
            "https://ww3.sinaimg.cn/bmiddle/5eef6257gw1ewuqdi4fn2g208c0cte83.gif",
            "https://ww2.sinaimg.cn/mw690/5eef6257gw1ewr7ytepbfg208c08cx6q.gif"
            ])
    }()
    
    /// 3.相册图片
    var album: (String, [PHAsset]) = {
        return ("相册图片", [])
    }()
}
public enum LPResult<Value> {
    case success(Value)
    case failure(Error)
}
extension LPPhotoBrowserVM {
    
    func numberOfSections() -> Int {
        return 3
    }
    
    func numberOfItems(in section: Int) -> Int {
        switch section {
        case 0: return local.1.count
        case 1: return network.1.count
        case 2: return album.1.count
        default: return 0
        }
    }
    
    func modelOfCell(at indexPath: IndexPath) -> Any? {
        switch indexPath.section {
        case 0: return local.1[indexPath.item]
        case 1: return network.1[indexPath.item]
        case 2: return album.1[indexPath.item]
        default: return nil
        }
    }
    
    func headerTitleOfCell(at section: Int) -> String? {
        switch section {
        case 0: return local.0
        case 1: return network.0
        case 2: return album.0
        default: return nil
        }
    }
}

extension LPPhotoBrowserVM {
    
    func number(of type: LPPhotoBrowserType) -> Int {
        switch type {
        case .local:   return local.1.count
        case .network: return network.1.count
        case .album:   return album.1.count
        default: return 0
        }
    }
    
    func sourceConvertible(at index: Int, of type: LPPhotoBrowserType, collectionView: UICollectionView) -> LPPhotoBrowserSourceConvertible? {
        switch type {
        case .local:
            let imageName = local.1[index]
            let photo = LPNetworkPhoto()
            photo.placeholder = imageView(in: collectionView, at: index, of: type)?.image
            
            if let url = Bundle.main.url(forResource: imageName, withExtension: nil) {
                photo.originalURL = url
            }
            return photo
        case .network:
            let photo = LPNetworkPhoto()
            photo.placeholder = imageView(in: collectionView, at: index, of: type)?.image
            photo.originalURL = URL(string: network.1[index])
            return photo
        default:
            return nil
        }
    }
    
    func imageView(in collectionView: UICollectionView, at index: Int, of type: LPPhotoBrowserType) -> UIImageView? {
        var section: Int = 0
        switch type {
        case .local: section = 0
        case .network: section = 1
        case .album: section = 2
        default: return nil
        }
        let cell = collectionView.cellForItem(at: IndexPath(item: index, section: section))
        guard let photoCell = cell as? LPPhotoBrowserCell else { return nil }
        return photoCell.imageView
    }
}
