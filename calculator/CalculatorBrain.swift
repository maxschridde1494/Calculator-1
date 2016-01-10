//
//  CalculatorBrain.swift
//  calculator
//
//  Created by Max Jacob Schridde on 12/28/15.
//  Copyright © 2015 Max Jacob Schridde. All rights reserved.
//

//MODEL

import Foundation

class CalculatorBrain{
    
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case Variable(String)
        case Constant(String, Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String{
            get{
                switch self{
                case .Operand(let operand):
                    return "\(operand)"
                case .Variable(let variable):
                    return "\(variable)"
                case .Constant(let constant, _):
                    return constant
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String: Op]()
    var variables = [String: Double]()
    
    var description: String{
        get{ return showHistory(opStack).result }
    }
    
    init(){
        func learnOp (op:Op){
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("/") {$1 / $0})
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("-") {$1 - $0})
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.Constant("pi", M_PI))
        learnOp(Op.UnaryOperation("+/-", {$0 * -1}))
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]){
        if !ops.isEmpty{
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op{
            case .Operand(let operand):
                return (operand, remainingOps)
            case .Variable(let variableValue):
                return (variables[variableValue], remainingOps)
            case .Constant(_, let constant):
                return (constant, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result{
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result{
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result{
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
            
        }
        return (nil, ops)
        
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remainder) left over.")
        return result
    }
    
    func pushOperand(operand: Double) -> Double?{
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double?{
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double?{
        if let operation = knownOps[symbol]{
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func removeLastOp(){
        if !opStack.isEmpty{
            opStack.removeLast()
        }
    }
    
    func clearVariables(){
        variables = [String: Double]()
    }
    
    func clearStack(){
        opStack = [Op]()
    }
    
    //this is not quite working
    private func showHistory(ops: [Op]) -> (result: String, remainingOps: [Op]){
        if !ops.isEmpty{
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op{
            case .Operand(let operand):
                return ("\(operand)", remainingOps)
            case .Constant(let constant, _):
                return ("\(constant)", remainingOps)
            case .Variable(let variable):
                return ("\(variable)", remainingOps)
            case .UnaryOperation(let operation, _):
                let operandEvaluation = showHistory(remainingOps)
                return (operation + "(" + operandEvaluation.result + ")" , remainingOps)
            case .BinaryOperation(let operation, _):
                let operand1Evaluation = showHistory(remainingOps)
                let operand2Evaluation = showHistory(operand1Evaluation.remainingOps)
                return ("(\(operand2Evaluation.result)\(operation)\(operand1Evaluation.result))", operand2Evaluation.remainingOps)
            }
        }
        return ("?", ops)
    }
}