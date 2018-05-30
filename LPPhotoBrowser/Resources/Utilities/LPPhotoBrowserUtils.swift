//
//  LPPhotoBrowserUtils.swift
//  LPPhotoBrowser
//
//  Created by pengli on 2018/5/29.
//  Copyright © 2018年 pengli. All rights reserved.
//

import Foundation
import LPLogger

/// 日志调试器
let log: LPLogger = {
    let log = LPLogger.shared
    let console = LPConsoleDestination(identifier: LPLogger.Constants.baseConsoleDestinationIdentifier)
    console.showThreadName = true
    
    #if DEBUG // 可在 “Build Settings” -> “Other Swift Flags” 下设置
    console.outputLevel = .debug
    #else
    console.outputLevel = .severe
    #endif
    
    log.add(destination: console)
    
    let emojiFormatter = LPPrePostFixLogFormatter()
    emojiFormatter.apply(prefix: "🗯🗯🗯 ", postfix: nil, to: .verbose)
    emojiFormatter.apply(prefix: "🔹🔹🔹 ", postfix: nil, to: .debug)
    emojiFormatter.apply(prefix: "ℹ️ℹ️ℹ️ ", postfix: nil, to: .info)
    emojiFormatter.apply(prefix: "⚠️⚠️⚠️ ", postfix: nil, to: .warning)
    emojiFormatter.apply(prefix: "‼️‼️‼️ ", postfix: nil, to: .error)
    emojiFormatter.apply(prefix: "💣💣💣 ", postfix: nil, to: .severe)
    log.formatters = [emojiFormatter]
    return log
}()
