//
//  ViewController.swift
//  Dont Panic
//
//  Created by Matt on 7/18/15.
//  Copyright © 2015 Gopher Studios. All rights reserved.
//

import UIKit
import Foundation
import WatchConnectivity
import CoreLocation
import MessageUI

class ViewController: UIViewController, UITextFieldDelegate, WCSessionDelegate, CLLocationManagerDelegate, MFMessageComposeViewControllerDelegate {

    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var theButton: UIButton!
    
    var tapTime1 : NSTimeInterval = 10 //used for keepings track of time between taps
    var tapTime2 : NSTimeInterval = 20 //used for keepings track of time between taps
    var tapTime3 : NSTimeInterval = 30 //used for keepings track of time between taps
    
    let session : WCSession!    //sets the watch connectivity session
    let locationManager = CLLocationManager() //sets the location manager for getting core location
    
    //in the below section of code we set up the user defaults, which are used for storing your default contact
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    
    //we need to set up the watch connect session if possible
    required init?(coder aDecoder: NSCoder) {
        self.session = WCSession.defaultSession()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(WCSession.isSupported()) {
            session.delegate = self
            session.activateSession()
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        self.phoneNumber.delegate = self
        if(self.userDefaults.valueForKey("emergencyContact") != nil){
            phoneNumber.text = self.userDefaults.valueForKey("emergencyContact") as? String
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    

    @IBAction func buttonPressed(sender: AnyObject) {
        tapTime1 = tapTime2
        tapTime2 = tapTime3
        tapTime3 = NSDate.timeIntervalSinceReferenceDate()
        if((tapTime3 - tapTime1) <= 3){
            //triple tapped quickely, initiate panic sequence
            tapTime1 = 10;
            tapTime2 = 20;
            tapTime3 = 30;
            panicInitated()
        }
    }
    
    
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        // verify that we've gotten a number at the "buttonOffset" key
        if let panicCode = message["panicInitiated"] as! Int? {
            
            if(panicCode == 1){
                
                panicInitated()
            }
        }
    }
    
    
    //main function that handles panic items
    func panicInitated(){
        NSLog("panic initiated")
        sendText()
                //callContact(self.phoneNumber.text!)
    }
    
    //function for setting up and sending a text to your emergency contact
    func sendText(){
        if let location = locationManager.location{
        
            //The CLGeocoder gives us an actual street address from the Core Location
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                print(location)
            
                if error != nil {
                    print("Reverse geocoder failed with error" + error!.localizedDescription)
                    return
                }
            
                //here we take the placemarks and set them to strings for use in the text message setup
                if let pm = placemarks!.first {
                    var textString : String
                    self.locationManager.stopUpdatingLocation()
                    let subThoroughfare = (pm.subThoroughfare != nil) ? pm.subThoroughfare : ""
                    let thoroughfare = (pm.thoroughfare != nil) ? pm.thoroughfare : ""
                    let locality = (pm.locality != nil) ? pm.locality : ""
                    let administrativeArea = (pm.administrativeArea != nil) ? pm.administrativeArea : ""
                
                    textString = "Help! I'm currently experiencing an emergency at \(subThoroughfare!) \(thoroughfare!) \(locality!) \(administrativeArea!)! -Sent using the 'Don't Panic' app for iOS"
                
                    if (MFMessageComposeViewController.canSendText()) {
                        let controller = MFMessageComposeViewController()
                        controller.body = textString
                        controller.recipients = [self.phoneNumber.text!]
                        controller.messageComposeDelegate = self
                        self.presentViewController(controller, animated: true, completion: nil)
                    }
                    else{
                        let alert = UIAlertController(title: "Unable to send text", message: "You are unable to send texts", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok!", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        NSLog("can't send text")
                    }
                }
                else {
                    print("Problem with the data received from geocoder")
                }
            })
        }
        else{
            let alert = UIAlertController(title: "Unable to get location", message: "You are unable to get a location", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok!", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //This function returns us from the message view controller once the message is actually sent.
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //calls your set contact. This isn't actually implemented, but is here for possible future watch use
    func callContact(phoneNumber : String){
        
        if(validate(phoneNumber)){
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(phoneNumber)")!)
        }
        else{
            NSLog("invalid phone number")
        }
    }
    
    
    //this function validates the phone number string using regex matching
    func validate(value: String) -> Bool {
        
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        
        let result =  phoneTest.evaluateWithObject(value)
        
        return result
        
    }
    
    //This handles any possible location manager update failures
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    //MARK: KEYBOARD CONTROLS
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
        userDefaults.setObject(textField.text, forKey: "emergencyContact")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if (textField.text!.isEmpty)
        {
            return false
        }
        return true
    }
}

