//
//  ViewController.swift
//  FXStepper
//
//  Created by Dong on 2019/4/29.
//  Copyright © 2019 dong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var stepper: FXStepper!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        _ = stepper.rx.value.subscribe(onNext: {[weak self] (value) in
            self?.valueLabel.text = "\(value)"
        })
        
    }

    @IBAction func stepperValueChanged(_ sender: FXStepper) {
        print(sender.value)
    }
    
}

