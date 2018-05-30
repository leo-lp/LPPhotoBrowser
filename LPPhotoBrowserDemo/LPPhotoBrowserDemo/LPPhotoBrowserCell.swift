//
//  LPPhotoBrowserCell.swift
//  LPPhotoBrowserDemo
//
//  Created by pengli on 2018/5/28.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

class LPPhotoBrowserCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bigPhotoFlagLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bigPhotoFlagLabel.layer.cornerRadius = 4.0
    }
    
    func bindData(with name: String, at indexPath: IndexPath) {
        bigPhotoFlagLabel.isHidden = true
        if indexPath.section == 0 {
            bindLocalImage(with: name)
        } else {
            bindNetworkImage(with: name)
        }
    }
    
    private func bindLocalImage(with imageNamed: String) {
        imageView.image = UIImage(named: imageNamed)
        
//        if let url = Bundle.main.url(forResource: imageNamed, withExtension: nil)
//            , let data = try? Data(contentsOf: url) {
//            imageView.image = UIImage(data: data)
//        }
        
        //        if (image.size.width > 3500 || image.size.height > 3500) {
        //            label.hidden = NO;
        //            label.text = @"大图";
        //            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //                UIImage *result = [YBImageBrowserUtilities scaleToSizeWithImage:image size:CGSizeMake(800, image.size.height / image.size.width * 800)];
        //                YB_MAINTHREAD_ASYNC(^{
        //                    imgView.image = result;
        //                })
        //            });
        //        } else {
        //            imgView.image = image;
        //        }
    }
    
    private func bindNetworkImage(with URLString: String) {
        let isGIF = URLString.hasSuffix(".gif")
        bigPhotoFlagLabel.isHidden = !isGIF
        if isGIF {
            bigPhotoFlagLabel.text = "gif"
        }
        
        imageView.kf.setImage(with: URL(string: URLString), placeholder: nil, options: nil, progressBlock: nil) { (img, error, type, url) in
            print("error=\(error)")
        }
    }
}
