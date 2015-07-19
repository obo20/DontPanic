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
    @IBOutlet weak var timeUntilCall: UILabel!
    
    let session : WCSession!    //sets the watch connectivity session
    let locationManager = CLLocationManager() //sets the location manager for getting core location
    
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
        panicInitated()
    }
    
    func secondsToMinutesSeconds (seconds : Int) -> (Int, Int) {
        return ((seconds % 3600) / 60, (seconds % 3600) % 60)
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
        let location = locationManager.location
        
        //The CLGeocoder gives us an actual street address from the Core Location
        CLGeocoder().reverseGeocodeLocation(location!, completionHandler: {(placemarks, error) -> Void in
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
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })

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
}

