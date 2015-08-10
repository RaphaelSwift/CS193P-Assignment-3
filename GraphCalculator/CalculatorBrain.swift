//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Adeline Rosat on 14.02.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private enum Op: Printable
    {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double, (Double -> String?)?)
        case BinaryOperation(String,Int,(Double,Double) -> Double,((Double, Double) -> String?)?)
        case Constant(String, () -> Double)
        case Variable(String)
        
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _,_):
                    return symbol
                case .BinaryOperation(let symbol, _,_,_):
                    return symbol
                case .Constant(let symbol,_):
                    return symbol
                case .Variable(let variable):
                    return variable
                }
            }
        }
        var precedence: Int {
            get {
            switch self {
            case .BinaryOperation(_, let precedence, _,_):
                return precedence
            default:
                return Int.max
                }
            }
        }
    }
    
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    // Dictionary of variables
    var variableValues = [String:Double]()

    
    var description: String {
        get {
            var (result, ops) = ("", opStack)
            do {
                var current: String?
                (current, ops, _) = description(ops)
                result = result == "" ? current! : "\(current!), \(result)"
            } while ops.count > 0
            return result
                
            }

        }
    

    
    
    init() {
        func learnOp (op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×",2, *, nil ))
        knownOps["÷"] = Op.BinaryOperation("÷",2, {$1 / $0},{divisor ,_ in return divisor == 0.0 ? "Division by zero": nil})
        knownOps["+"] = Op.BinaryOperation("+",1, +, nil)
        knownOps["−"] = Op.BinaryOperation("−",1,{$1 - $0},nil)
        knownOps["√"] = Op.UnaryOperation("√", sqrt,{ $0 < 0 ? "Cannot do square root of a negative number" : nil})
        knownOps["sin"] = Op.UnaryOperation("sin", sin, nil)
        knownOps["cos"] = Op.UnaryOperation("cos", cos, nil)
        knownOps["±"] = Op.UnaryOperation("±",{-$0},nil)
        knownOps["Pi"] = Op.Constant("Pi") {M_PI}
    }
    
    typealias PropertyList = AnyObject
    var program: PropertyList { // guaranteed to be PropertyList
        
        get {
            
            return opStack.map { $0.description}
//            var returnValue: Array<String>()
//            for op in opStack {
//                returnValue.append(op.description)
//            }
//            return returnValue
        }
        
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps [opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                    newOpStack.append(.Operand(operand))
                    } else {
                        newOpStack.append(.Variable(opSymbol))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    
    private var error: String?
    
    private func description(ops: [Op]) -> (result: String?, remainingOps: [Op], precedence: Int?)
    {
        if !ops.isEmpty{
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (String(format: "%g", operand) , remainingOps, op.precedence)
            case .UnaryOperation(let symbol, _, _):
                let operandDescription = description(remainingOps)
                if var operand = operandDescription.result {
                    if op.precedence > operandDescription.precedence {
                        operand = "(\(operand))"
                    }
                    return ("\(symbol)(\(operand))", operandDescription.remainingOps, op.precedence)
                }
            case .BinaryOperation(let symbol,_, _, _):
                let op1Evaluation = description(remainingOps)
                if var operand1 = op1Evaluation.result {
                        if op.precedence > op1Evaluation.precedence {
                        operand1 = "(\(operand1))"
                    }
                    let op2Evaluation = description(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return ("\(operand2) \(symbol) \(operand1)", op2Evaluation.remainingOps, op.precedence)
                    }
                }
                
            case .Constant(let symbol,_):
                return (symbol,remainingOps,op.precedence)
                
            case .Variable(let variable):
                return (variable, remainingOps,op.precedence)
            }
            
            
        }
        
        return ("?", ops, Int.max)
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op])
    {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation, let errorTest):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    if let errorDescription = errorTest?(operand) {
                        error = errorDescription
                        return (nil, operandEvaluation.remainingOps)
                    }
                    return (operation(operand), operandEvaluation.remainingOps)
                }
                
            case .BinaryOperation(_,_, let operation, let errorTest):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        if let errorMessage = errorTest?(operand1, operand2) {
                            error = errorMessage
                            return (nil, op2Evaluation.remainingOps)
                        }
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .Constant(_, let operation):
                return (operation(),remainingOps)
                
            case .Variable(let variable):
                if let variableValue = variableValues[variable] {
                    return (variableValue, remainingOps)
                }
                
                
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        error = nil
        let (result, remainder) = evaluate(opStack)
        //println ("\(opStack) = \(result) with \(remainder) left over")
        return result
        
    }
    
    func evaluateAndReportErrors() -> AnyObject? {
        let (result, _) = evaluate(opStack)
        return result != nil ? result: error
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
        
    }

    // push variable
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
        
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        
        return evaluate()
        
    }
    
    func removeLastOnTheStack() -> Double? {
        if !opStack.isEmpty {
        opStack.removeLast()
        }
        return evaluate()
    }
    
    // clear the operations stack
    func clearStack () {
        opStack = []
    }
}
