//
//  InstaPost.swift
//  Instasham
//
//  Created by Jeanne Luning Prak on 6/20/16.
//  Copyright © 2016 Jeanne Luning Prak. All rights reserved.
//

import Foundation
import UIKit
import Parse
import ParseUI

class Comment {
    var user : PFUser
    var comment : String
    
    init(user : PFUser, comment : String) {
        self.user = user
        self.comment = comment
    }
}

class InstaPost {
    class func postUserImage(image: UIImage?, withCaption caption: String?, withCompletion completion: PFBooleanResultBlock?) {
        // Create Parse object PFObject
        let post = PFObject(className: "Post")
        
        // Add relevant fields to the object
        post["media"] = getPFFileFromImage(image) // PFFile column type
        post["author"] = PFUser.currentUser() // Pointer column type that points to PFUser
        post["caption"] = caption
        post["likesCount"] = 0
        post["likes"] = [PFUser]()
        post["comments"] = [String]()
        post["userComments"] = [PFUser]()
        
        // Save object (following function will save the object in Parse asynchronously)
        post.saveInBackgroundWithBlock(completion)
    }
    
    class func updateProfilePic(image: UIImage?) {
        let user = PFUser.currentUser()
        user!["profile"] = getPFFileFromImage(image)
        user!.saveInBackground()
    }
    
    class func removeFromList(user : PFUser, userList : [PFUser]) -> [PFUser] {
        do {
            try user.fetchIfNeeded()
        } catch _ {
            return userList
        }
        var newUsers = [PFUser]()
        for nextUser in userList {
            do {
                try nextUser.fetchIfNeeded()
            } catch _ {
                return userList
            }
            if(nextUser.username != user.username) {
                newUsers.append(nextUser)
            }
        }
        return newUsers
    }
    
    class func updateFollowing(user : PFUser) {
        let currentUser = PFUser.currentUser()
        var following = currentUser!["following"] as! [PFUser]
        if(!InstaPost.followingUser(user)) {
            following.append(user)
            PFUser.currentUser()!["following"] = following
            PFUser.currentUser()!.saveInBackgroundWithBlock() {
                (post, error) -> Void in
                if error != nil {
                    print(error)
                }
            }
            let notif = Notification(toNotify: user, doneBy: currentUser!, action: "followed", doneTo: "you")
            notif.recordNotification()
        } else {
            currentUser!["following"] = removeFromList(user, userList: following)
            currentUser!.saveInBackground()
        }
    }

    class func getPFFileFromImage(image: UIImage?) -> PFFile? {
        // check if image is not nil
        if let image = image {
            // get image data and check if that is not nil
            if let imageData = UIImagePNGRepresentation(image) {
                return PFFile(name: "image.png", data: imageData)
            }
        }
        return nil
    }
    
    class func followingUser(user : PFUser) -> Bool {
        return followingOtherUser(PFUser.currentUser()!, user: user)
    }
    
    class func followingOtherUser(currentUser : PFUser, user : PFUser) -> Bool {
        let me : PFUser = currentUser
        do {
            try me.fetchIfNeeded()
        } catch _ {
            return false
        }
        if let following = me["following"] {
            for nextUser in following as! [PFUser] {
                do {
                    try nextUser.fetchIfNeeded()
                } catch _ {
                    return false
                }
                print(user.username!)
                print(nextUser.username!)
                if user.username! == nextUser.username! {
                    return true
                }
            }
        }
        return false
    }

    
    var photo : PFFile
    var caption : String
    var likes : Int
    var timestamp : NSDate
    var postedBy : String
    var user : PFUser
    var id : String
    var userLikes : [PFUser]
    var comments : [String]
    var userComments : [PFUser]
    
    init(photo : PFFile, caption : String, postedBy : PFUser, timeStamp : NSDate?, id : String, likes : Int, userLikes : [PFUser], comments : [String], userComments : [PFUser]) {
        self.photo = photo
        self.caption = caption
        self.likes = likes
        self.userLikes = userLikes
        self.timestamp = timeStamp!
        self.postedBy = postedBy.username!
        self.user = postedBy
        self.id = id
        self.comments = comments
        self.userComments = userComments
    }
    
    func updateComments(comment : Comment) {
        self.comments.append(comment.comment)
        self.userComments.append(comment.user)
        let query = PFQuery(className:"Post")
        query.getObjectInBackgroundWithId(self.id) {
            (post, error) -> Void in
            if error != nil {
                print(error)
            } else {
                var newComments = post!["comments"] as! [String]
                newComments.append(comment.comment)
                var newUserComments = post!["userComments"] as! [PFUser]
                newUserComments.append(comment.user)
                post!["comments"] = newComments
                post!["userComments"] = newUserComments
                post!.saveInBackgroundWithBlock() { (post, error) -> Void in
                    if error != nil {
                        print(error)
                    }
                }
                let notif = Notification(toNotify: self.user, doneBy: comment.user, action: "commented on", doneTo: "your post")
                notif.recordNotification()
            }
        }
    }
    
    func userLiked(user : PFUser) -> Bool {
        for liked in userLikes {
            do {
                try liked.fetchIfNeeded()
            } catch _ {
                return false
            }
            if(liked.username == user.username) {
                return true
            }
        }
        return false
    }
    
    func updateLikes(user : PFUser) {
        if(!userLiked(user)) {
            self.likes += 1
            self.userLikes.append(user)
            let query = PFQuery(className:"Post")
            query.getObjectInBackgroundWithId(self.id) {
                (post, error) -> Void in
                if error != nil {
                    print(error)
                } else {
                    post!["likesCount"] = self.likes
                    var newLikes = post!["likes"] as! [PFUser]
                    newLikes.append(user)
                    post!["likes"] = newLikes
                    post!.saveInBackground()
                    let notif = Notification(toNotify: self.user, doneBy: user, action: "liked", doneTo: "your post")
                    notif.recordNotification()
                }
            }
        }
        
    }
    
    
    
    func removeUser(user : PFUser) -> [PFUser] {
        var newLikes = [PFUser]()
        for liked in userLikes {
            do {
                try liked.fetchIfNeeded()
            } catch _ {
                return userLikes
            }
            if(liked.username != user.username) {
                newLikes.append(liked)
            }
        }
        return newLikes
    }
    
    func unlike(user : PFUser) {
        if(userLiked(user)) {
            self.likes -= 1
            self.userLikes = self.removeUser(user)
            let query = PFQuery(className:"Post")
            query.getObjectInBackgroundWithId(self.id) {
                (post, error) -> Void in
                if error != nil {
                    print(error)
                } else {
                    post!["likesCount"] = self.likes
                    post!["likes"] = self.removeUser(user)
                    post!.saveInBackground()
                }
            }
        }
        
    }
}