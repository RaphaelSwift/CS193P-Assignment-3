//
//  StatisticsViewController.swift
//  GraphCalculator
//
//  Created by Raphael Neuenschwander on 10.08.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {

    var text: String = "" {
        didSet {
            textView?.text = text
        }
    }

    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView?.text = text
        }
    }
    
    override var preferredContentSize: CGSize {
        get {
            if textView != nil && presentingViewController != nil {
                return textView.sizeThatFits(presentingViewController!.view.bounds.size)
            }
            else {
                return super.preferredContentSize
            }
        }
        
        set {
            super.preferredContentSize = newValue
        }
        
    }
}
