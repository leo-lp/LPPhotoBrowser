//
//  LPNavigationBar.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/6/25.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

public protocol LPNavigationBarDataSource: class {
    var totalCount: Int { get set }
    var currentIndex: Int { get set }
    
    var title: String? { get set }
}
public class LPNavigationBar: UIView {
    private(set) var titleLabel = UILabel()
    
    fileprivate(set) var total: Int = 0
    fileprivate(set) var index: Int = 0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = #colorLiteral(red: 0, green: 0.8470588235, blue: 0.7882352941, alpha: 1)
        alpha = 0.95
        
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 0.0, y: frame.height - 44.0, width: frame.width, height: 44.0)
    }
}

extension LPNavigationBar: LPNavigationBarDataSource {
    
    public var totalCount: Int {
        get { return total }
        set {
            total = newValue
            titleLabel.text = "\(index+1)/\(total)"
        }
    }
    
    public var currentIndex: Int {
        get { return index }
        set {
            index = newValue
            titleLabel.text = "\(index+1)/\(total)"
        }
    }
    
    public var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
}
