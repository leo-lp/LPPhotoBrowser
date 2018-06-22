//
//  LPPhotoBrowserModels.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/5/29.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

public struct LPPhotoBrowserType: OptionSet, Hashable {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let `default` = LPPhotoBrowserType(rawValue: 1 << 1)
    public static let network   = LPPhotoBrowserType(rawValue: 1 << 2)
    public static let album     = LPPhotoBrowserType(rawValue: 1 << 3)
}

public typealias LPProgress = (_ percent: Float) -> Void
public typealias LPCompletion = (_ image: UIImage?) -> Void

public protocol LPPhotoBrowserSourceConvertible {
    var asImage: UIImage? { get }
    
    func asImage(_ progress: LPProgress?, completion: @escaping LPCompletion)
}

extension UIImage: LPPhotoBrowserSourceConvertible {
    public var asImage: UIImage? { return self }
    
    public func asImage(_ progress: LPProgress?, completion: @escaping LPCompletion) {
        return completion(self)
    }
}
