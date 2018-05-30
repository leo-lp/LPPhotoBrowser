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
        titleLabel.text = indexPath.section == 0 ? "本地图片" : "网络图片"
    }
}
