//
//  LPPhotoBrowserCellHeader.swift
//  LPPhotoBrowserDemo
//
//  Created by pengli on 2018/5/28.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

class LPPhotoBrowserCellHeader: UICollectionReusableView {
    @IBOutlet weak var titleLabel: UILabel!
    
    func bindData(at indexPath: IndexPath) {
        var title: String
        switch indexPath.section {
        case 0:
            title = "本地图片"
        case 1:
            title = "网络图片"
        case 2:
            title = "相册图片"
        default:
            title = "未知来源"
        }
        titleLabel.text = title
    }
}
