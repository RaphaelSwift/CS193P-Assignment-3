//
//  GraphViewController.swift
//  GraphCalculator
//
//  Created by Raphael Neuenschwander on 07.08.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//



import UIKit

class GraphViewController: UIViewController, GraphViewDataSource, GraphViewDelegate {
    
    private struct Gestures {
        static let PinchAction: Selector = "scale:"
        static let DoubleTapAction: Selector = "moveOrigin:"
        static let PanAction: Selector = "moveGraph:"
    }
    
    private struct Keys {
        static let Scale = "GraphViewController.Scale"
        static let Origin = "GraphViewController.Origin"
    }
    
    var operandStack: [String] = [] {
        didSet{
            updateUI()
        }
    }
    
    var program: AnyObject {
        get {
            return brain.program
        }
        set {
            brain.program = newValue
        }
    }
    
    private func updateUI() {
        graphView?.setNeedsDisplay()
        title = "\(operandStack.last)"
    }
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    private let brain = CalculatorBrain()
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            
            graphView.delegate = self
            graphView.dataSource = self
            
            if let scale = userDefaults.objectForKey(Keys.Scale) as? CGFloat {
                graphView.pointsPerUnits = scale
            }
            
            if let origin = userDefaults.objectForKey(Keys.Origin) as? String {
                graphView.newAxeOrigin = CGPointFromString(origin)
            }
            

            
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: Gestures.PinchAction))
            
            let doubleTapGestureRecognizer = UITapGestureRecognizer(target: graphView, action: Gestures.DoubleTapAction)
            doubleTapGestureRecognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(doubleTapGestureRecognizer)
            
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: Gestures.PanAction))
        }
    }
    
    //MARK: - GraphViewDataSource
    
    func graphForGraphView(xAxisValue: CGFloat, sender: GraphView) -> CGPoint? {
        
        brain.variableValues["M"] = Double(xAxisValue)
        
        if let y = brain.evaluate() {
            
            let point = CGPoint(x: xAxisValue, y: CGFloat(y))
            if !point.x.isNormal || !point.y.isNormal {
                return nil
            } else {
                return point
            }
        }
        return nil
    }
    
    func scale(scale: CGFloat, sender: GraphView) {
        userDefaults.setObject(scale, forKey: Keys.Scale)
    }

    func origin(origin: CGPoint, sender: GraphView) {
        userDefaults.setObject(NSStringFromCGPoint(origin), forKey: Keys.Origin)
    }
    

}
