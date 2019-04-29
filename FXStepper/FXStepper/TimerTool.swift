//
//  TimerTool.swift
//  BcaasWallet
//
//  Created by iris_luo on 2018/10/15.
//  Copyright © 2018年 orangeblock.com. All rights reserved.
//


import Foundation

/// Timeout wrapps a callback deferral that may be cancelled.
///
/// Usage:
/// let timer = Timeout(1.0) { println("1 second has passed.") }
///
public class TimeoutTimer: NSObject {
    
    private var timer: NormalTimer?
    private var callback: (() -> Void)?
    
    /// timer初始化
    public init(_ delaySeconds: Double, _ callback: @escaping () -> Void) {
        super.init()
        self.callback = callback
        self.timer = NormalTimer.init(timeInterval: delaySeconds, repeats: false, {[weak self] in
            self?.invoke()
        })
    }
    /// timer執行結束
    private func invoke() {
        self.callback?()
        // Discard callback and timer.
        self.callback = nil
        self.timer?.cancel()
        self.timer = nil
    }
    /// timer撤銷
    public func cancel() {
        self.callback = nil
        self.timer?.cancel()
    }
    
}

/// 普通定时器(防止控制器被强引用无法被释放)
public class NormalTimer  {
    
    private var timer: Timer?
    private var callback: (() -> Void)?
    private var repeats : Bool?
    
    /// timer初始化
    ///
    /// - Parameters:
    ///   - timeInterval: 时间间隔
    ///   - repeats: 是否重复
    ///   - callback: 回调
    public init(timeInterval: TimeInterval,repeats:Bool, _ callback: @escaping () -> Void) {
        
        self.callback = callback
        self.timer = Timer.init(timeInterval: timeInterval, target: self, selector: #selector(invoke), userInfo: nil, repeats: repeats)
        self.repeats = repeats
        RunLoop.current.add(self.timer!, forMode: .common)
    }
    /// timer執行
    @objc private func invoke() {
        self.callback?()
        if repeats == false {
            self.callback = nil
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    /// timer撤銷
    public func cancel() {
        self.timer?.invalidate()
        self.callback = nil
        self.timer = nil
    }
    
    
}
