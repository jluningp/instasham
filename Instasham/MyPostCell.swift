//
//  MyPostCell.swift
//  Instasham
//
//  Created by Jeanne Luning Prak on 6/21/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit
import ParseUI

class MyPostCell: UITableViewCell {

    
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var photo: PFImageView!

    var post : InstaPost?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setPost(post : InstaPost) {
        self.post = post
    }
    
    
    
    
   
    @IBAction func likePost(sender: AnyObject) {
        if(post!.userLiked(PFUser.currentUser()!)) {
            post!.unlike(PFUser.currentUser()!)
            self.likes.text = getLikeString()
            likeButton.setBackgroundImage(UIImage(named : "like"), forState: .Normal)
        } else {
            post!.updateLikes(PFUser.currentUser()!)
            self.likes.text = getLikeString()
            likeButton.setBackgroundImage(UIImage(named : "filledHeart"), forState: .Normal)
        }
    }
    
    func getLikeString() -> String {
        if(post!.likes == 0) {
            return "0 likes"
        } else if(post!.likes < 5) {
            let firstLike = post!.userLikes[0]
            do {
                try firstLike.fetchIfNeeded()
            } catch _ {
                return "\(post!.likes) likes"
            }
            var likedBy = "<3 \(firstLike.username!)"
            for i in 1..<post!.likes {
                let user = post!.userLikes[i]
                do {
                    try user.fetchIfNeeded()
                } catch _ {
                    return "\(post!.likes) likes"
                }
                likedBy += ", \(user.username!)"
            }
            return likedBy
        } else {
            return "\(post!.likes) likes"
        }
    }
    
    func getCommentsString() -> String {
        let numComments = self.post!.comments.count
        if(numComments == 0) {
            return ""
        } else if(numComments > 2) {
            var commentString = ""
            for i in 0..<2 {
                let newUser = self.post!.userComments[i]
                do {
                    try newUser.fetchIfNeeded()
                } catch _ {
                    return "[Could Not Load Comments]"
                }
                commentString += "\n\(newUser.username!) - \(self.post!.comments[i])"
            }
            return commentString
        } else {
            var commentString = ""
            for i in 0..<numComments {
                let newUser = self.post!.userComments[i]
                do {
                    try newUser.fetchIfNeeded()
                } catch _ {
                    return "[Could Not Load Comments]"
                }
                commentString += "\n\(newUser.username!) - \(self.post!.comments[i])"
            }
            return commentString
        }
    }
    
    func loadUI() {
        if let post = post {
            self.photo.file = post.photo
            self.photo.loadInBackground()
            self.caption.text = "\(post.postedBy): \(post.caption)"
            self.username.text = post.postedBy
            self.likes.text = getLikeString()
            if(post.userLiked(PFUser.currentUser()!)) {
                likeButton.setBackgroundImage(UIImage(named : "filledHeart"), forState: .Normal)
            } else {
                likeButton.setBackgroundImage(UIImage(named : "like"), forState: .Normal)
            }
        }
    }

}
