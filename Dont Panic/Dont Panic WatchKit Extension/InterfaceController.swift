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

//    let session : WCSession!    //sets the watch connectivity session
//    
//    override init() {
//        if(WCSession.isSupported()) {
//            session =  WCSession.defaultSession()
//        }
//        else {
//            session = nil
//        }
//    }
    
    @IBOutlet var labelOutlet: WKInterfaceLabel!
    
    
    @IBAction func buttonOutlet() {
        
        if(WCSession.isSupported()) {
            
            // create a message dictionary to send
//            let message = ["panicInitiated" : NSString()]
//            
//            session.sendMessage(message, replyHandler: { (content:[String : AnyObject]) -> Void in
//                print("Our counterpart sent something back. This is optional")
//                }, errorHandler: {  (error ) -> Void in
//                    print("We got an error from our paired device : " + error.domain)
//            })
        }
    }
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
