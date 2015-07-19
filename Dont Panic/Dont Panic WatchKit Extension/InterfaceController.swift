//
//  InterfaceController.swift
//  Dont Panic WatchKit Extension
//
//  Created by Matt on 7/18/15.
//  Copyright © 2015 Gopher Studios. All rights reserved.
//

import WatchKit
import WatchConnectivity
import Foundation


class InterfaceController: WKInterfaceController, WCSessionDelegate {

    let session : WCSession!    //sets the watch connectivity session
    var tapTime1 : NSTimeInterval = 10 //used for keepings track of time between taps
    var tapTime2 : NSTimeInterval = 20 //used for keepings track of time between taps
    var tapTime3 : NSTimeInterval = 30 //used for keepings track of time between taps
    var emergencyState = false
    
    @IBOutlet var myButton: WKInterfaceButton!
    @IBOutlet var labelOutlet: WKInterfaceLabel!
    
    override init() {
        if(WCSession.isSupported()) {
            session =  WCSession.defaultSession()
        }
        else {
            session = nil
        }
        
    }
    
    @IBAction func buttonPressed() {
        tapTime1 = tapTime2
        tapTime2 = tapTime3
        tapTime3 = NSDate.timeIntervalSinceReferenceDate()
        
        if((tapTime3 - tapTime1) <= 3)
        {
            if(emergencyState == false)
            {
                self.emergencyState = true
                self.labelOutlet.setText("EMERGENCY")
                self.myButton.setTitle("Triple tap to clear!")
                self.myButton.setBackgroundColor(UIColor(red: 255.0, green: 0.0, blue: 0.0, alpha: 1.0))
                tapTime1 = 10; //resetting
                tapTime2 = 20; //resetting
                tapTime3 = 30; //resetting
                watchPanicInitiated(1)
                
            }
            //used for future emergency cancelling
            else
            {
                emergencyState = false
                self.labelOutlet.setText("Don't Panic 😎")
                self.myButton.setTitle("Triple Tap for Emergency")
                self.myButton.setBackgroundColor(UIColor(red: 153.0/255, green: 204.0/255, blue: 255.0/255, alpha: 1.0))
                tapTime1 = 10; //resetting
                tapTime2 = 20; //resetting
                tapTime3 = 30; //resetting
            }
        }
    }
    
    func watchPanicInitiated(panicCode : Int){
        if(WCSession.isSupported()) {
            
            // create a message dictionary to send
            let message = ["panicInitiated" : panicCode]
            
            session.sendMessage(message, replyHandler: { (content:[String : AnyObject]) -> Void in
                print("Our counterpart sent something back. This is optional")
                }, errorHandler: {  (error ) -> Void in
                    print("We got an error from our paired device : " + error.domain)
            })
        }
    }
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if(WCSession.isSupported()) {
            session.delegate = self
            session.activateSession()
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
