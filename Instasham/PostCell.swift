//
//  PostCell.swift
//  Instasham
//
//  Created by Jeanne Luning Prak on 6/20/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import UIKit
import ParseUI

class PostCell: UITableViewCell {

    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var makeComment: UIButton!
    @IBOutlet weak var numComments: UIButton!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var captionText: UILabel!
    @IBOutlet weak var photo: PFImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var comments: UILabel!
    
    
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
            var likedBy = "\u{2764} \(firstLike.username!)"
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
    
    func dateString(date : NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .NoStyle
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        return dateFormatter.stringFromDate(date)
    }
    
    func loadUI() {
        if let post = post {
            self.photo.file = post.photo
            self.photo.loadInBackground()
            self.captionText.text = "\(post.postedBy): \(post.caption)"
            self.likes.text = getLikeString()
            if(post.userLiked(PFUser.currentUser()!)) {
                likeButton.setBackgroundImage(UIImage(named : "filledHeart"), forState: .Normal)
            } else {
                likeButton.setBackgroundImage(UIImage(named : "like"), forState: .Normal)
            }
            let commentCount = post.comments.count
            if(commentCount > 1) {
                self.numComments.setTitle("View all \(post.comments.count) comments", forState: .Normal)
            } else if(commentCount == 1){
                self.numComments.setTitle("View 1 comment", forState: .Normal)
            } else {
                self.numComments.setTitle("No comments yet", forState: .Normal)
            }
            self.timeStamp.text = "Posted " + dateString(post.timestamp)
        }
    }

}
