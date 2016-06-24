//
//  NotifCell.swift
//  Instasham
//
//  Created by Jeanne Luning Prak on 6/24/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit
import ParseUI

class NotifCell: UITableViewCell {

    @IBOutlet weak var notifText: UILabel!
    @IBOutlet weak var profileImage: PFImageView!
    var notif : Notification?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func addNotif(notif : Notification) {
        self.notif = notif
    }
    
    func getUsername(user : PFUser) -> String {
        do {
            try user.fetchIfNeeded()
        } catch _ {
            return ""
        }
        return user.username! as String
    }
    
    func loadUI() {
        self.notifText.attributedText = getAttributedCaption(getUsername(self.notif!.doneBy), notifString: self.notif!.printNotification())
        loadProfilePic()
    }
    
    func circleProfile() {
        profileImage.layer.masksToBounds = false
        profileImage.layer.cornerRadius = profileImage.frame.size.height/2
        profileImage.clipsToBounds = true
    }
    
    func loadProfilePic() {
        circleProfile()
        self.profileImage.file = self.notif!.doneBy["profile"] as? PFFile
        self.profileImage.loadInBackground()
    }
    
    func getAttributedCaption(username : String, notifString : String) -> NSMutableAttributedString {
        
        /* Find the position of the search string. Cast to NSString as we want
         range to be of type NSRange, not Swift's Range<Index> */
        let range = (notifString as NSString).rangeOfString(username)
        
        /* Make the text at the given range bold. Rather than hard-coding a text size,
         Use the text size configured in Interface Builder. */
        let attributedCaption = NSMutableAttributedString(string: notifString)
        attributedCaption.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(self.notifText.font.pointSize), range: range)
        
        return attributedCaption
    }
    

}
