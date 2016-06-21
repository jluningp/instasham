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

    @IBOutlet weak var username_box: UILabel!
    @IBOutlet weak var captionText: UILabel!
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
    
    func loadUI() {
        if let post = post {
            self.photo.file = post.photo
            self.photo.loadInBackground()
            self.captionText.text = "\(post.postedBy): \(post.caption)"
            self.username_box.text = post.postedBy
        }
    }

}
