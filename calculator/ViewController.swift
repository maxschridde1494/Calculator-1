//
//  ViewController.swift
//  calculator
//
//  Created by Max Jacob Schridde on 12/2/15.
//  Copyright © 2015 Max Jacob Schridde. All rights reserved.
//

import UIKit
import Darwin

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    //model
    var brain = CalculatorBrain()
    
    var userIsInTheMiddleOfTypingANumber = false
    var displayValueIsOnlyADecimalPoint = false
    
    let pi = M_PI

    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber{
            if digit == "." && display.text!.rangeOfString(".") != nil {
            
            }else{
                display.text = display.text! + digit
            }
        }else{
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func constant(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if !displayValueIsOnlyADecimalPoint{
            if let constant = sender.currentTitle{
                if let result = brain.performOperation(constant){
                    displayValue = result
                }else{
                    displayValue = 0
                }
            }
            history.text = brain.description
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if !displayValueIsOnlyADecimalPoint{
            if let operation = sender.currentTitle{
                if let result = brain.performOperation(operation){
                    displayValue = result
                    
                }else{
                    displayValue = nil
                }
            }
            history.text = "=" + brain.description
        }
    }
    
    @IBAction func changeSign(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber{
            let originalDisplay = display.text!
            if let displayVal = displayValue{
                displayValue = -1 * displayVal
                userIsInTheMiddleOfTypingANumber = true
                //some hack code
                //check number has no decimal points and no decimal values
                //deals with float created when multiplying by 1
                if displayVal % 1 == 0{
                    if originalDisplay.rangeOfString(".") == nil{dropLastCharacterOfDisplayText()}
                    display.text = String(display.text!.characters.dropLast())
                }

            }
        }else{
            if let operation = sender.currentTitle{
                if let result = brain.performOperation(operation){
                    displayValue = result
                }else{
                    displayValue = nil
                }
                history.text = "=" + brain.description
            }
        }
    }
    
    func dropLastCharacterOfDisplayText() {
        display.text = String(display.text!.characters.dropLast())
    }
    
    var displayValue:Double? {
        get{
            if let text = display.text{
                return NSNumberFormatter().numberFromString(text)!.doubleValue
            }else{
                return nil
            }
        }
        set{
            if let newVal = newValue{
                display.text = "\(newVal)"
                userIsInTheMiddleOfTypingANumber = false
            }else{
                display.text = " "
            }
        }
    }
    
    @IBAction func enter() {
        if display.text! == "." {
            displayValueIsOnlyADecimalPoint = true
        }else{
            displayValueIsOnlyADecimalPoint = false
            userIsInTheMiddleOfTypingANumber = false
            if let displayVal = displayValue{
                if let result = brain.pushOperand(displayVal){
                    displayValue = result
                }
            }
            else{
                displayValue = nil
            }
            history.text = "=" + brain.description
        }
    }
    
    @IBAction func setMemory() {
        if let displayVal = displayValue{
            brain.variables["M"] = displayVal
        }
        if let result = brain.evaluate(){
            displayValue = result
        }else{
            displayValue = nil
        }
        userIsInTheMiddleOfTypingANumber = false
    }
    
    @IBAction func getMemory() {
        if let result = brain.pushOperand("M"){
            displayValue = result
        }
    }
    
    @IBAction func undo() {
        if userIsInTheMiddleOfTypingANumber{
            display.text = String(display.text!.characters.dropLast())
            if display.text!.characters.count == 0{
                display.text = "0"
                userIsInTheMiddleOfTypingANumber = false
            }
        }else{
            brain.removeLastOp()
            history.text = brain.description
            if let result = brain.evaluate(){
                displayValue = result
            }else{
                displayValue = nil
            }
        }
    }
    
    @IBAction func clear() {
        userIsInTheMiddleOfTypingANumber = false
        displayValueIsOnlyADecimalPoint = false
        display.text = "0"
        history.text = ""
        
        brain.clearStack()
        brain.clearVariables()
    }

}

