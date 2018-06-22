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
        guard let url = Bundle.main.url(forResource: imageNamed, withExtension: nil)
            , let data = try? Data(contentsOf: url)
            , let image = UIImage(data: data) else { return }
        //guard let image = UIImage(named: imageNamed) else { return }
        
        if image.size.width >= 3840 || image.size.height >= 3840 {
            bigPhotoFlagLabel.isHidden = false
            bigPhotoFlagLabel.text = " 4K大图 "
            DispatchQueue.global().async {
                let width: CGFloat = 375.0
                let height: CGFloat = image.size.height / image.size.width * width
                let scaledImage = image.lp_reSizeImage(CGSize(width: width, height: height))
                DispatchQueue.main.async {
                    self.imageView.image = scaledImage
                }
            }
        } else {
            bigPhotoFlagLabel.isHidden = true
            imageView.image = image
        }
    }
    
    private func bindNetworkImage(with URLString: String) {
        let url = URL(string: URLString)
        
        let resizing = ResizingImageProcessor(referenceSize: CGSize(width: 200, height: 200), mode: .aspectFill)
        let options: KingfisherOptionsInfo = [.processor(resizing), .preloadAllAnimationData]
        imageView.kf.setImage(with: url,
                              placeholder: nil,
                              options: options,
                              progressBlock: nil) { (img, error, type, url) in
            if img?.images == nil {
                self.bigPhotoFlagLabel.isHidden = true
            } else {
                self.bigPhotoFlagLabel.isHidden = false
                self.bigPhotoFlagLabel.text = " 动态图 "
            }
            
            if let error = error {
                print("URLString=\(URLString)")
                print("error=\(error)")
            }
        }
    }
}
