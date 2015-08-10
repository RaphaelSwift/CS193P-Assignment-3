//
//  ViewController.swift
//  Calculator
//
//  Created by Adeline Rosat on 06.02.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {


    @IBOutlet weak var display: UILabel!
    
    // Display the history
    @IBOutlet weak var displayHistory: UILabel!
  
    var userIsInTheMiddleOfTypingANumber = false
    
    private var brain = CalculatorBrain()
    
    private struct Calculator {
        static let SegueIdentifier = "Show Graph"
    }

    
    // Append digit to the calculator's display
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
      }
    
    // Append a digit in the form of a comma, to accept "legal" float number
    @IBAction func appendFloat(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if display.text?.rangeOfString(".") == nil || userIsInTheMiddleOfTypingANumber == false {
        
        if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
        } else {
            
        }
    }
    
    //clear the display, history, operandStack etc.
    @IBAction func reset() {
        display.text = "\(0)"
        displayHistory.text = " "
        brain.clearStack()
        brain.variableValues.removeAll()
        userIsInTheMiddleOfTypingANumber = false
    }
    
    // "Backspace" button
    @IBAction func backspace() {
        if userIsInTheMiddleOfTypingANumber {
        if let text = display.text {
        let numberElements = count(text)
        
        switch numberElements {
            
        case 1 : display.text = dropLast(display.text!)
                 display.text = "0"
                 userIsInTheMiddleOfTypingANumber = false
            
        default: display.text = dropLast(display.text!)
            
        }
        }
        }
        brain.removeLastOnTheStack()
        displayHistory.text = brain.description
        display.text = nil
    }

    
    // convert the display value to minus/plus value
    @IBAction func plusMinus() {
        if userIsInTheMiddleOfTypingANumber {
            if display.text?.rangeOfString("-") != nil {
                display.text = dropFirst(display.text!)
            }
            else { display.text = "-" + display.text!
            }
        }else {
            if let result = brain.performOperation("±") {
                displayValue = result
            } else {
                displayValue = nil
            }
        }
    }

    
    // Perform the operations
    @IBAction func operate(sender: UIButton) {
        let operation=sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = nil
            }
        }
        
    }
        
        
//        switch operation {
//        case "×": performOperation { $0 * $1 }
//        case "÷": performOperation { $1 / $0 }
//        case "+": performOperation { $0 + $1 }
//        case "−": performOperation { $1 - $0 }
//        case "√": performOperation { sqrt($0)}
//        case "sin": performOperation { sin($0)}
//        case "cos": performOperation { cos($0)}
//        case "Pi": display.text = "\(M_PI)"
//                    enter()
//        default: break
//        }

    
    @IBAction func setVariable() {
        brain.variableValues["M"] = displayValue
        if let result = brain.evaluate() {
            displayValue = result
        }
        userIsInTheMiddleOfTypingANumber = false
        
    }
    
    @IBAction func getVariable() {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let result = brain.pushOperand("M") {
            displayValue = result
        }else {
            displayValue = nil
        }
        
    }
    
//    //Function to perform the operation using 2 numbers
//    func performOperation(operation: (Double,Double) -> Double) {
//        if operandStack.count >= 2 {
//            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
//            displayHistory.text = displayHistory.text! + "= "
//            enter()
//            
//        }
//    }
//    
//    //Function to perform the operation using one number
//    func performOperation(operation: (Double) -> Double) {
//        if operandStack.count >= 1 {
//            displayValue = operation(operandStack.removeLast())
//            enter()
//        }
//    }
    
    // Declare an array which will store the numbers to then perform the operations
//    var operandStack = [Double]()
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
//        operandStack.append(displayValue)
//        println("operandStack = \(operandStack)")
        if let valueDisplay = displayValue {
        if let result = brain.pushOperand(valueDisplay) {
            displayValue = result
        } else {
            displayValue = nil
        }
        }

        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var destination = segue.destinationViewController as? UIViewController
        
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController
        }
        
        if let gvc = destination as? GraphViewController {
            if let identifier = segue.identifier {
                
                switch identifier {
                case Calculator.SegueIdentifier:
                    gvc.operandStack = brain.program as? [String] ?? []
                    gvc.program = brain.program
                default: break
                }
            }
        }
    }
    
    // Create a new variable, which is the text display transformed into a double
    var displayValue: Double? {
        get {
            if let text = display.text{
            return NSNumberFormatter().numberFromString(text)?.doubleValue
            } else { return nil}
        }
        
        set {
//            display.text = "\(newValue!)"
//            userIsInTheMiddleOfTypingANumber = false
            if let displayText = newValue {
                display.text = "\(displayText)"
            } else {
                if let result = brain.evaluateAndReportErrors() as? String {
                    display.text = result }
                    else {
                        display.text = " "
                    }
            displayHistory.text = brain.description + " ="
            

        }
        }
    
    }
}