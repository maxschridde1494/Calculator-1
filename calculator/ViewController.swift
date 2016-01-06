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
    var operationCompleted = false
    
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
            history.text = brain.showHistory()
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if !displayValueIsOnlyADecimalPoint{
            operationCompleted = true
            if let operation = sender.currentTitle{
                if let result = brain.performOperation(operation){
                    displayValue = result
                    
                }else{
                    displayValue = 0
                }
            }
            history.text = brain.showHistory()
            operationCompleted = false
        }
    }
    
    @IBAction func changeSign(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber{
            let originalDisplay = display.text!
            displayValue = -1 * displayValue
            userIsInTheMiddleOfTypingANumber = true
            //some hack code
            //check number has no decimal points and no decimal values
            //deals with float created when multiplying by 1
            if displayValue % 1 == 0{
                if originalDisplay.rangeOfString(".") == nil{dropLastCharacterOfDisplayText()}
                display.text = String(display.text!.characters.dropLast())
            }
            
            
        }else{
            if let operation = sender.currentTitle{
                operationCompleted = true
                if let result = brain.performOperation(operation){
                    displayValue = result
                }else{
                    displayValue = 0
                }
                operationCompleted = false
            }
        }
    }
    
    func dropLastCharacterOfDisplayText() {
        display.text = String(display.text!.characters.dropLast())
    }
    
    @IBAction func enter() {
        if display.text! == "." {
            displayValueIsOnlyADecimalPoint = true
        }else{
            displayValueIsOnlyADecimalPoint = false
            userIsInTheMiddleOfTypingANumber = false
            if let result = brain.pushOperand(displayValue){
                displayValue = result
            }else{
                displayValue = 0
            }
            history.text = brain.showHistory()
        }
    }
    @IBAction func backspace() {
        if userIsInTheMiddleOfTypingANumber{
            display.text = String(display.text!.characters.dropLast())
            if display.text!.characters.count == 0{
                display.text = "0"
                userIsInTheMiddleOfTypingANumber = false
            }
        }
    }
    
    @IBAction func clear() {
        userIsInTheMiddleOfTypingANumber = false
        displayValueIsOnlyADecimalPoint = false
        operationCompleted = false
        display.text = "0"
        history.text = ""
        
        brain.clear()
    }
    
    var displayValue:Double {
        get{
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set{
            if operationCompleted == true{
                display.text = "=\(newValue)"
            }else{
                display.text = "\(newValue)"
            }
            userIsInTheMiddleOfTypingANumber = false
        }
    }

}

