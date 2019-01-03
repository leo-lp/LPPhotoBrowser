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
    
    func bindData(with value: Any?, at indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if let imageName = value as? String {
                bindLocalImage(with: imageName)
            }
        case 1:
            if let URLString = value as? String {
                bindNetworkImage(with: URLString)
            }
        case 2:
            break
        default:
            break
        }
    }
    
    private func bindLocalImage(with imageNamed: String) {
//        guard let url = Bundle.main.url(forResource: imageNamed, withExtension: nil)
//            , let data = try? Data(contentsOf: url)
//            , let image = UIImage(data: data) else { return }
        //guard let image = UIImage(named: imageNamed) else { return }
        
        guard let url = Bundle.main.url(forResource: imageNamed, withExtension: nil) else { return }
        
        let resizing = ResizingImageProcessor(referenceSize: CGSize(width: 200, height: 200), mode: .aspectFill)
        let options: KingfisherOptionsInfo = [.processor(resizing), .cacheMemoryOnly]
        imageView.kf.setImage(with: url, placeholder: nil, options: options, progressBlock: nil) { (image, error, cacheType, url) in
            guard let image = image else { return }
            
            print("local cacheType=\(cacheType, image.size)")
            
            if imageNamed.contains("4k") {
                self.bigPhotoFlagLabel.isHidden = false
                self.bigPhotoFlagLabel.text = " 4K大图 "
            } else if imageNamed.contains("GIF") {
                self.bigPhotoFlagLabel.isHidden = false
                self.bigPhotoFlagLabel.text = " 动态图 "
            } else {
                self.bigPhotoFlagLabel.isHidden = true
            }
        }
    }
    
    private func bindNetworkImage(with URLString: String) {
        let url = URL(string: URLString)
//        let resizing = ResizingImageProcessor(referenceSize: CGSize(width: 100, height: 100), mode: .aspectFill)
        
        let crop = CroppingImageProcessor(size: CGSize(width: 150, height: 150))
        let options: KingfisherOptionsInfo = [.processor(crop)]
        imageView.kf.setImage(with: url,
                              placeholder: nil,
                              options: options,
                              progressBlock: nil) { (img, error, type, url) in
            if URLString.contains("gif") {
                self.bigPhotoFlagLabel.isHidden = false
                self.bigPhotoFlagLabel.text = " 动态图 "
            } else {
                self.bigPhotoFlagLabel.isHidden = true
            }
            
            print("network cacheType=\(type, img?.size)")
                                
            if let error = error {
                print("URLString=\(URLString)")
                print("error=\(error)")
            }
        }
    }
}
