//
//  GraphAnalysisViewController.swift
//  GraphCalculator
//
//  Created by Raphael Neuenschwander on 10.08.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//

import UIKit

class GraphAnalysisViewController: GraphViewController, UIAdaptivePresentationControllerDelegate
{

    private struct Statistics {
        static let SegueIdentifier = "Show Stats"
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let svc = segue.destinationViewController as? StatisticsViewController {
            
            if let pvc = svc.presentationController {
                pvc.delegate = self
            }
            
            if let identifier = segue.identifier {
                
                switch identifier {
                case Statistics.SegueIdentifier: svc.text = "Max Value: \(graphView.maxYValue) \nMin Value : \(graphView.minYValue)"
                default: break
                    
                }
            }
        }
    }
    
    
    // MARK: - UIAdaptivePresentationControllerDelegate
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}
