//
//  GraphView.swift
//  GraphCalculator
//
//  Created by Raphael Neuenschwander on 07.08.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//


// EXTRA CREDIT 1 : The graph and axe is completly and continuously redrawn when the user pan or pinch
// EXTRA CREDIT 2 : Solution: Create a snapshot of the current graph

import UIKit

protocol GraphViewDataSource: class {
    func graphForGraphView(xAxisValue: CGFloat, sender: GraphView) -> CGPoint?
}

@objc protocol GraphViewDelegate {
    optional func scale(scale: CGFloat, sender: GraphView)
    optional func origin(origin: CGPoint, sender: GraphView)
}

@IBDesignable

class GraphView: UIView {
    
    @IBInspectable var axeColor: UIColor = UIColor.blueColor() { didSet { setNeedsDisplay()} }
    @IBInspectable var pointsPerUnits: CGFloat = 100 {
        didSet {
            setNeedsDisplay()
            delegate?.scale!(pointsPerUnits, sender: self)
        }
    }

    private var snapshot: UIView?
    
    private var resolution: CGFloat {
        get {
           return contentScaleFactor
        }
    }
    
    var newAxeOrigin: CGPoint?
    var maxYValue: CGFloat = 0.0
    var minYValue: CGFloat = 0.0
    
    private var axeOrigin : CGPoint {
        get {
            return newAxeOrigin ?? convertPoint(center, fromView: superview) }
        set {
            newAxeOrigin = newValue
            delegate?.origin!(newValue, sender: self)
            setNeedsDisplay()
        }
    }
    
    private var graphFrame : CGRect {
        return convertRect(frame, fromView: superview)
    }
    
    private let axesDrawer = AxesDrawer()
    
    weak var dataSource: GraphViewDataSource?
    var delegate: GraphViewDelegate?

    
    override func drawRect(rect: CGRect) {
        axesDrawer.color = axeColor
        axesDrawer.contentScaleFactor = resolution
        axesDrawer.drawAxesInRect(graphFrame, origin: axeOrigin, pointsPerUnit: pointsPerUnits)
        drawGraph(axeOrigin, pointsPerUnit: pointsPerUnits)
        
    }
    
    // Draws an x vs. y graph
    private func drawGraph(origin: CGPoint, pointsPerUnit: CGFloat ) {
        let path = UIBezierPath()
        
        var xValue = bounds.minX
        
        while xValue <= bounds.maxX {
            let scaleAndOriginAccountedValue = (xValue - origin.x) / pointsPerUnits
            
            if let point = dataSource?.graphForGraphView(scaleAndOriginAccountedValue, sender: self) {
                
                let convertedPointToDraw = CGPoint(x: (point.x * pointsPerUnits) + origin.x, y: origin.y - (point.y * pointsPerUnits) )
                
                if let alignedPoint = alignedPoint(x: convertedPointToDraw.x, y: convertedPointToDraw.y, insideBounds: bounds) {
                    if !path.empty { path.addLineToPoint(alignedPoint) }
                    path.moveToPoint(alignedPoint)
                }
                
                if maxYValue < point.y { maxYValue = point.y }
                if minYValue > point.y { minYValue = point.y }
            }
            xValue += 1 / resolution
        }
        path.stroke()
    }
    
    // Zoom the entire graph
    func scale(gesture: UIPinchGestureRecognizer) {
        
        switch gesture.state {
        case .Began:
            snapshot = self.snapshotViewAfterScreenUpdates(false)
            self.addSubview(snapshot!)
        case .Changed:
            let touch = gesture.locationInView(self)
            snapshot?.frame.size.height *= gesture.scale
            snapshot?.frame.size.width *= gesture.scale
            snapshot?.frame.origin.x = snapshot!.frame.origin.x * gesture.scale + (1 - gesture.scale) * touch.x
            snapshot?.frame.origin.y = snapshot!.frame.origin.y * gesture.scale + (1 - gesture.scale) * touch.y
            gesture.scale = 1
            
        case .Ended:
            let changedScale = snapshot!.frame.size.height / self.frame.size.height
            pointsPerUnits *= changedScale
            snapshot?.removeFromSuperview()
            snapshot = nil
            
        default: break
        }
        
        
//        if gesture.state == UIGestureRecognizerState.Changed {
//            pointsPerUnits *= gesture.scale
//            gesture.scale = 1
//        }
    }
    
    // Moves the origin of the Graph
    func moveOrigin(gesture: UITapGestureRecognizer) {
        if gesture.state == .Ended {
            axeOrigin = gesture.locationInView(self)
        }
    }
    
    // Moves the entire graph
    func moveGraph(gesture : UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .Began:
            snapshot = self.snapshotViewAfterScreenUpdates(false)
            snapshot?.alpha = 0.8
            self.addSubview(snapshot!)
        case .Changed:
            let translation = gesture.translationInView(self)
            snapshot!.center.x += translation.x
            snapshot!.center.y += translation.y
            gesture.setTranslation(CGPointZero, inView: self)
        case .Ended:
            let newOrigin = CGPoint(x: axeOrigin.x + snapshot!.frame.origin.x, y: axeOrigin.y + snapshot!.frame.origin.y)
            axeOrigin = newOrigin
            snapshot!.removeFromSuperview()
            snapshot = nil
            
        default: break
        }
    }
    
    
    private func alignedPoint(#x: CGFloat, y: CGFloat, insideBounds: CGRect? = nil) -> CGPoint?
    {
        let point = CGPoint(x: align(x), y: align(y))
        if let permissibleBounds = insideBounds {
            if (!CGRectContainsPoint(permissibleBounds, point)) {
                return nil
            }
        }
        return point
    }
    
    private func align(coordinate: CGFloat) -> CGFloat {
        return round(coordinate * resolution) / resolution
    }
}
