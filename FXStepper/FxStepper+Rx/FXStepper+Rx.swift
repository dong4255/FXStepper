//
//  FXStepper+Rx.swift
//  FXStepper
//
//  Created by Dong on 2019/4/29.
//  Copyright © 2019 dong. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: FXStepper {
    
    public var value: ControlProperty<Double> {
        return base.rx.controlProperty(editingEvents: .valueChanged,
                                       getter: { stepper in
                                        stepper.value
        }, setter: { (stepper, value) in
            stepper.value = value
        })
    }
}
