//
//  ViewController.swift
//  Dont Panic
//
//  Created by Matt on 7/18/15.
//  Copyright © 2015 Gopher Studios. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var timeUntilCall: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.phoneNumber.delegate = self
        self.phoneNumber.text = "260-413-6395"
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func timeStepper(sender: UIStepper) {
        
        let (minutes,seconds) = secondsToMinutesSeconds(Int(sender.value))
        var secondsString = "00"
        
        if (seconds < 10){
            secondsString = "0\(seconds)"
        }
        else{
            secondsString = "\(seconds)"
        }
        
        self.timeUntilCall.text = ("\(minutes):\(secondsString)")
    }

    @IBAction func buttonPressed(sender: AnyObject) {
        let phoneNumberString = self.phoneNumber.text
        callContact(phoneNumberString!)
    }
    
    func secondsToMinutesSeconds (seconds : Int) -> (Int, Int) {
        return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func callContact(phoneNumber : String){
        
        if(validate(phoneNumber)){
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(phoneNumber)")!)
        }
        else{
            NSLog("invalid phone number")
        }
    }
    
    func validate(value: String) -> Bool {
        
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        
        let result =  phoneTest.evaluateWithObject(value)
        
        return result
        
    }
}

