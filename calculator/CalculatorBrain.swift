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
        case Constant(String, Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String{
            get{
                switch self{
                case .Operand(let operand):
                    return "\(operand)"
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
    
    func performOperation(symbol: String) -> Double?{
        if let operation = knownOps[symbol]{
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func clear(){
        opStack = [Op]()
    }
    
    private func showHistory(ops: [Op]) -> (result: String?, remainingOps: [Op]){
        if !ops.isEmpty{
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op{
            case .Operand(let operand):
                return ("\(operand)", remainingOps)
            case .Constant(let constant, _):
                return ("\(constant)", remainingOps)
            case .UnaryOperation(let operation, _):
                let operandEvaluation = showHistory(remainingOps)
                if let remainingHistory = operandEvaluation.result{
                    return (operation + "(" + remainingHistory + ")" , remainingOps)
                }
            case .BinaryOperation(let operation, _):
                let op1Evaluation = showHistory(remainingOps)
                if let operand1 = op1Evaluation.result{
                    let op2Evaluation = showHistory(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result{
                        return ("(\(operand1)\(operation)\(operand2))", op2Evaluation.remainingOps)
                    }
                }
                return (operation, ops)
            }
        }
        return (nil, ops)
    }
    
    func showHistory() -> String?{
        let (result, _) = showHistory(opStack)
        print(result)
        return result
    }
}