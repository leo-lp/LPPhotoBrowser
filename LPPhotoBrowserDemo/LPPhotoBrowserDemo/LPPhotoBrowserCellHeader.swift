//
//  LPPhotoBrowserCellHeader.swift
//  LPPhotoBrowserDemo
//
//  Created by pengli on 2018/5/28.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

class LPPhotoBrowserCellHeader: UICollectionReusableView {
    @IBOutlet weak var titleButton: UIButton!
    
    func bindData(with title: String?, at indexPath: IndexPath, target: Any?, action: Selector) {
        titleButton.setTitle(title, for: .normal)
        if indexPath.section == 2 {
            titleButton.addTarget(target, action: action, for: .touchUpInside)
        }
    }
}
