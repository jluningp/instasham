//
//  CommentCell.swift
//  Instasham
//
//  Created by Jeanne Luning Prak on 6/22/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class CommentCell: UITableViewCell {

    @IBOutlet weak var profilepic: PFImageView!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var username: UILabel!
    var currentComment : Comment?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func circleProfile() {
        profilepic.layer.masksToBounds = false
        profilepic.layer.cornerRadius = profilepic.frame.size.height/2
        profilepic.clipsToBounds = true
    }
    
    func loadProfilePic() {
        circleProfile()
        self.profilepic.file = self.currentComment!.user["profile"] as? PFFile
        self.profilepic.loadInBackground()
    }

    
    func setComment(comment : Comment) {
        self.currentComment = comment
    }
    
    func loadUI() {
        let user = self.currentComment!.user
        do {
            try user.fetchIfNeeded()
        } catch _ {
            username.text = "[Failed to load comment]"
            return
        }
        username.text = user.username
        comment.text = self.currentComment!.comment
        loadProfilePic()
    }

}
