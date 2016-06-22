//
//  CommentCell.swift
//  Instasham
//
//  Created by Jeanne Luning Prak on 6/22/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    
    @IBOutlet weak var profilepic: UIImageView!
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
    }

}
