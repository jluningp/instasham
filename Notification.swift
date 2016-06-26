//
//  Notification.swift
//  Instasham
//
//  Created by Jeanne Luning Prak on 6/24/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import Foundation
import Parse

class Notification {
    var toNotify : PFUser
    var doneBy : PFUser
    var action : String
    var doneTo : String
    
    init(toNotify : PFUser, doneBy : PFUser, action : String, doneTo : String) {
        self.toNotify = toNotify
        self.doneBy = doneBy
        self.action = action
        self.doneTo = doneTo
    }
    
    func recordNotification() {
        let notif = PFObject(className: "Notification")
        
        // Add relevant fields to the object
        notif["toNotify"] = self.toNotify
        notif["doneBy"] = self.doneBy
        notif["action"] = self.action
        notif["doneTo"] = self.doneTo
        
        // Save object (following function will save the object in Parse asynchronously)
        notif.saveInBackground()
        
    }
    
    func printNotification() -> String {
        do {
            try self.doneBy.fetchIfNeeded()
        } catch _ {
            return ""
        }
        do {
            try self.toNotify.fetchIfNeeded()
        } catch _ {
            return ""
        }
        return "\(doneBy.username!) \(action) \(doneTo)"
    }
}