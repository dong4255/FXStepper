//
//  FXStepper.swift
//  ExchangeIOS
//
//  Created by Dong on 2019/4/22.
//  Copyright © 2019 orangeblock. All rights reserved.
//

import UIKit

@IBDesignable
public class FXStepper: UIControl {
    
    /// ➖ 按钮
    private let minusButton = UIButton(type: .system)
    /// 分割线
    private let separatorView = UIView()
    /// ➕ 按钮
    private let plusButton = UIButton(type: .system)
    /// 当前步进按钮
    private var currentStepButton : UIButton? {
        didSet {
            if currentStepButton == nil {
                minusButton.isEnabled = true
                plusButton.isEnabled = true
            }else if currentStepButton == minusButton {
                plusButton.isEnabled = false
            }else if currentStepButton == plusButton {
                minusButton.isEnabled = false
            }
        }
    }
    /// 步进计时器
    private var stepTimer : NormalTimer?
    
/************************************************************/
    
    /// 数值
    public var value:Double = 0.0 {
        didSet {
            if value < minimumValue {
                value = minimumValue
            }
            if value > maximumValue {
                value = maximumValue
            }
        }
    }
    /// 最小值
    public var minimumValue:Double = 0.0 {
        didSet {
            if minimumValue > maximumValue {
                maximumValue = minimumValue
            }
            if minimumValue > value {
                value = minimumValue
            }
        }
    }
    /// 最大值
    public var maximumValue:Double = 100.0 {
        didSet {
            if maximumValue < minimumValue {
                minimumValue = maximumValue
            }
        }
    }
    /// 步进值
    public var stepValue:Double = 1.0
    /// 按住按钮时是否自动持续递增或递减
    public var autorepeat = true
//    /// 控制值是否在[minimumValue,maximumValue]区间内循环
//    var wraps = false

    public convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createSubviews()
    }
    
    // MARK: - 创建子视图
    /// 创建子视图
    private func createSubviews() {
        
        self.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 4
        
        // ➖ 按钮
        minusButton.setTitle("-", for: .normal)
        minusButton.setTitleColor(UIColor.green, for: .normal)
        minusButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        minusButton.addTarget(self, action: #selector(stepButtonTouchDownAction(_:)), for: .touchDown)
        minusButton.addTarget(self, action: #selector(stepButtonTouchUpInsideAction(_:)), for: .touchUpInside)
        minusButton.addTarget(self, action: #selector(stepButtonTouchUpOutsideAction(_:)), for: .touchUpOutside)
        minusButton.addTarget(self, action: #selector(stepButtonTouchDragExitAction(_:)), for: .touchDragExit)
        minusButton.addTarget(self, action: #selector(stepButtonTouchDragEnterAction(_:)), for: .touchDragEnter)
        minusButton.addTarget(self, action: #selector(stepButtonTouchCancelAction(_:)), for: .touchCancel)
        
        // 分割线
        separatorView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        
        // ➕ 按钮
        plusButton.setTitle("+", for: .normal)
        plusButton.setTitleColor(UIColor.red, for: .normal)
        plusButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        plusButton.addTarget(self, action: #selector(stepButtonTouchDownAction(_:)), for: .touchDown)
        plusButton.addTarget(self, action: #selector(stepButtonTouchUpInsideAction(_:)), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(stepButtonTouchUpOutsideAction(_:)), for: .touchUpOutside)
        plusButton.addTarget(self, action: #selector(stepButtonTouchDragExitAction(_:)), for: .touchDragExit)
        plusButton.addTarget(self, action: #selector(stepButtonTouchDragEnterAction(_:)), for: .touchDragEnter)
        plusButton.addTarget(self, action: #selector(stepButtonTouchCancelAction(_:)), for: .touchCancel)
        
        self.addSubview(minusButton)
        self.addSubview(separatorView)
        self.addSubview(plusButton)
        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        minusButton.frame = CGRect(x: 0, y: 0, width: (bounds.width - 1) / 2.0, height: bounds.height)
        
        separatorView.frame = CGRect(x: minusButton.frame.maxX, y: 8, width: 1, height: bounds.height - 16)
        
        plusButton.frame = CGRect(x: separatorView.frame.maxX, y: 0, width: (bounds.width - 1) / 2.0, height: bounds.height)
        
    }
    
    // MARK: 开始计数
    private func startCount() {
        changeValue()
        stepTimer = nil
        var tempValue = 0
        stepTimer = NormalTimer(timeInterval: 0.7, repeats: true, {[weak self] in
            tempValue += 1
            self?.changeValue()
            if tempValue == 4 {
                self?.startFastCount()
            }
        })
    }
    
    // MARK: 开始快速计数
    private func startFastCount() {
        stepTimer?.cancel()
        stepTimer = nil
        stepTimer = NormalTimer(timeInterval: 0.1, repeats: true, {[weak self] in
            self?.changeValue()
        })
    }
    
    // MARK: 结束计数
    private func endCount() {
        stepTimer?.cancel()
    }
    
    // MARK: 改变数值
    private func changeValue() {
        if currentStepButton == plusButton {
            if self.value >= maximumValue { return }
            self.value += stepValue
            self.sendActions(for: .valueChanged)
        }else if currentStepButton == minusButton {
            if self.value <= minimumValue { return }
            self.value -= stepValue
            self.sendActions(for: .valueChanged)
        }
    }
    
    
    // MARK: 步进按钮 手指按下事件
    @objc private func stepButtonTouchDownAction(_ sender:UIButton) {
        if currentStepButton != nil { return }
        currentStepButton = sender
        
        if autorepeat {
            startCount()
        }
    }
    
    // MARK: 步进按钮 手指抬起事件
    @objc private func stepButtonTouchUpInsideAction(_ sender:UIButton) {
        if autorepeat {
            endCount()
        }else {
            changeValue()
        }
        
        currentStepButton = nil
    }
    
    // MARK: 步进按钮 手指拖动到按钮范围内
    @objc private func stepButtonTouchDragEnterAction(_ sender:UIButton) {
        if autorepeat {
            startCount()
        }
    }
    
    // MARK: 步进按钮 手指拖动到按钮范围外
    @objc private func stepButtonTouchDragExitAction(_ sender:UIButton) {
        if autorepeat {
            endCount()
        }
    }
    
    // MARK: 步进按钮 手指在按钮范围外抬起
    @objc private func stepButtonTouchUpOutsideAction(_ sender:UIButton) {
        if autorepeat {
            endCount()
        }
        currentStepButton = nil
    }
    
    // MARK: 步进按钮 手指取消点击
    @objc private func stepButtonTouchCancelAction(_ sender:UIButton) {
        if autorepeat {
            endCount()
        }
        currentStepButton = nil
    }
    
}
